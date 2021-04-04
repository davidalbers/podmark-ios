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
        }.store(in: &cancellables)
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
}
