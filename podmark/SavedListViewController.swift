import UIKit
import Combine
import SDWebImage
import SwiftUI

class SavedListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var tableView: UITableView = UITableView()
    var presenter = SavedListsPresenter()
    var folderName: String?
    var items = [SavedItem]()
    private var cancellables: Set<AnyCancellable> = []
    private var shareOptionsBuilder = ShareOptionsBuilder()

    override func loadView() {
        super.loadView()
        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        tableView.dataSource = self
        tableView.delegate = self
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.register(SavedItemCellView.self, forCellReuseIdentifier: "SavedItem")

        presenter.$items.sink { [weak self] items in
            self?.items = items
            self?.tableView.reloadData()
        }.store(in: &cancellables)
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(shareTapped)),
            UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3.decrease.circle"), style: .plain, target: self, action: #selector(sortTapped)),
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped)),
        ]
        
        self.title = folderName!
    }
    
    override func viewDidAppear(_ animated: Bool) {
        presenter.loadFolder(folderName: folderName!)
    }
    
    @objc func shareTapped() {
        let shareActionSheet = UIAlertController(title: "Share as...", message: nil, preferredStyle: .actionSheet)
        let actions = shareOptionsBuilder.getAlertControllerButtons(action: { shareType in
            let shareSheet = UIActivityViewController(activityItems: [self.shareOptionsBuilder.getShareData(type: shareType, items: self.presenter.items)], applicationActivities: nil)
            self.present(shareSheet, animated: true)
        })
        actions.forEach { action in
            shareActionSheet.addAction(action)
        }

        self.present(shareActionSheet, animated: true)
    }
    
    @objc func sortTapped() {
        let alert = UIAlertController(title: "Sort by...", message: nil, preferredStyle: .actionSheet)
        let actions = presenter.getSortButtons(action: { type in
            self.presenter.sort = type
        })
        actions.forEach { action in
            alert.addAction(action)
        }

        self.present(alert, animated: true)
    }
    
    @objc func addTapped() {
        let addItemView = ManualAddItemView(
            presenter: ManualAddItemPresenter(folder: folderName!),
            dismissAction: {
                self.presenter.loadFolder(folderName: self.folderName!)
                self.dismiss(animated: true, completion: nil)
            }
        )
        let vc = UIHostingController(rootView: addItemView)
        self.present(vc, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedItem", for: indexPath as IndexPath) as! SavedItemCellView
        
        let item = items[indexPath.row]
        cell.title.text = item.title
        cell.podcastName.text = item.podcastName
        
        let placeHolderImage = UIImage(systemName: "questionmark.square")?.withTintColor(UIColor(named: "tint") ?? .gray, renderingMode: .alwaysOriginal)
        
        cell.artwork.sd_setImage(with: URL(string: item.imageURL), placeholderImage: placeHolderImage)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let savedItemVC = UIHostingController(rootView: SavedItemDetailsScreen(item: items[indexPath.row]))
        navigationController!.pushViewController(savedItemVC, animated: true)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = items.remove(at: indexPath.row)
            presenter.deleteSavedItem(id: item.id)
        }
    }
}
