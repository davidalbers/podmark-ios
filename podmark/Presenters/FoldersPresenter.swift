import Foundation
import SwiftUI

class FoldersPresenter: ObservableObject {
    @Published var folders = [String]()
    private var db = SavedListsDB()

    init() {
        getFolders()
        if (folders.isEmpty) {
            db.addFolder(folderName: "Favorites")
            getFolders()
        }
    }
    
    
    func getFolders() {
        folders = db.getFolders().sorted()
    }
    
    func addFolder(folderName: String?) {
        if let folderName = folderName,
           !folderName.isEmpty {
            db.addFolder(folderName: folderName)
            getFolders()
        }
    }
    
    func deleteFolder(_ folderName: String) {
        folders.removeAll(where: { $0 == folderName})
        db.deleteFolder(folderName: folderName)
    }
}
