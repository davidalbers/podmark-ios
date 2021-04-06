import UIKit
import Combine
import SwiftUI

class MainViewController: UITableViewController {

    var presenter = FoldersPresenter()
    private var cancellables: Set<AnyCancellable> = []
    var folders = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Folders"
        presenter.$folders.sink { [weak self] folders in
            self?.folders = folders
            self?.tableView?.reloadData()
        }.store(in: &cancellables)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
    }

    @objc func addTapped() {
        let alert = UIAlertController(title: "Add a folder", message: nil, preferredStyle: .alert)
        alert.addTextField {
            $0.placeholder = "Folder name"
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let submitAction = UIAlertAction(title: "Add", style: .default) { [unowned alert, weak self] _ in
            self?.presenter.addFolder(folderName: alert.textFields![0].text)
        }

        alert.addAction(cancelAction)
        alert.addAction(submitAction)

        present(alert, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folders.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FolderCellView
        let folder = folders[indexPath.row]
        cell.folderName.text = folder
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let savedListView = SavedListView(folderName: folders[indexPath.row])
        let savedListVC = UIHostingController(rootView: savedListView)
        navigationController!.pushViewController(savedListVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let folderName = folders.remove(at: indexPath.row)
            presenter.deleteFolder(folderName)
        }
    }
}
