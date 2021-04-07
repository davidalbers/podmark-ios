import UIKit
import Combine
import SDWebImage

class SavedListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var tableView: UITableView = UITableView()
    var presenter = SavedListsPresenter()
    var folderName: String?
    var items = [SavedItem]()
    private var cancellables: Set<AnyCancellable> = []

    override func loadView() {
        super.loadView()
        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.dataSource = self
        tableView.delegate = self
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(SavedItemCellView.self, forCellReuseIdentifier: "SavedItem")

        presenter.$items.sink { [weak self] items in
            self?.items = items
            self?.tableView.reloadData()
        }.store(in: &cancellables)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let folderName = folderName {
            presenter.loadFolder(folderName: folderName)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedItem", for: indexPath as IndexPath) as! SavedItemCellView
        
        cell.title.text = items[indexPath.row].title
        cell.podcastName.text = items[indexPath.row].podcastName
        cell.artwork.sd_setImage(with: URL(string: items[indexPath.row].imageURL))
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

}
