import Foundation
import SwiftUI

class SavedListsPresenter: ObservableObject {
    public enum Sort: String, CaseIterable {
        case alpha = "Alphabetically"
        case dateDescending = "Date added, newest first"
        case dateAscending = "Date added, oldest first"
    }
    @Published var sort = Sort.dateDescending {
        didSet {
            items = sortItems(items)
        }
    }
    @Published var items = [SavedItem]()
    @Published var folders = [String]()
    
    var currentItem: SavedItem? = nil
    
    private var db = SavedListsDB()
    
    init() {
        getFolders()
    }

    func getFolders() {
        folders = db.getFolders().sorted()
    }
    
    private func sortItems(_ items: [SavedItem]) -> [SavedItem] {
        items.sorted { left, right in
            switch sort {
            case .alpha:
                return left.podcastName < right.podcastName
            case .dateAscending:
                return left.dateAdded.iso8601withFractionalSeconds ?? Date.init() < right.dateAdded.iso8601withFractionalSeconds ?? Date.init()
            case .dateDescending:
                return left.dateAdded.iso8601withFractionalSeconds ?? Date.init() > right.dateAdded.iso8601withFractionalSeconds ?? Date.init()
            }
        }
    }
        
    func getFolderIndex(folderName: String) -> Int {
        return folders.firstIndex(of: folderName) ?? 0
    }
    
    func loadFolder(folderName: String) {
        items = sortItems(db.openFolder(folderName: folderName))
    }
    
    func deleteSavedItem(id: String) {
        db.deleteSavedItem(id: id)
        items.removeAll(where: { $0.id == id })
    }
    
    func getSortButtons(action: @escaping (Sort) -> Void) -> [UIAlertAction] {
        var buttons = [UIAlertAction]()
        Sort.allCases.forEach { type in
            buttons.append(UIAlertAction(title: type.rawValue, style: .default , handler:{ (UIAlertAction) in
                action(type)
            }))
        }
        buttons.append(UIAlertAction(title: "Cancel", style: .cancel))
        return buttons
    }
}
