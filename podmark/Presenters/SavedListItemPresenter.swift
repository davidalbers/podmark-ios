import Foundation

class SavedListItemPresenter: ObservableObject {
    @Published var folders = [String]()
    @Published var folderIndex = 0 {
        didSet {
            let folderName = folders[folderIndex]
            if folderName != self.currentItem.folder {
                self.currentItem.folder = folderName
                save()
            }
        }
    }
    private var originalId: String
    
    @Published public var currentItem: SavedItem

    private var db = SavedListsDB()

    init(item: SavedItem) {
        currentItem = item
        originalId = item.sharedURL
        getFolders()
    }
    
    func save() {
        db.insertSavedItem(savedItem: self.currentItem)
    }
    
    private func getFolders() {
        folders = db.getFolders().sorted()
        folderIndex = folders.firstIndex(of: currentItem.folder) ?? 0
    }
}
