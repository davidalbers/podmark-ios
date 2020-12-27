import Foundation
import Combine

class ManualAddItemPresenter: ObservableObject {
    private var folder: String
    @Published var link = "" {
        didSet {
            showSetLinkButton = !link.isEmpty
        }
    }
    @Published private var shareViewModel = ShareViewModel()
    @Published var defaultItem: SavedItem
    @Published var showSetLinkButton = false
    private var subscription: AnyCancellable? = nil
    private var savedListsPresenter = SavedListsDB()
    
    init(folder: String) {
        self.folder = folder
        self.defaultItem = SavedItem(
            id: UUID().uuidString,
            sharedURL: "",
            imageURL: "",
            title: "",
            podcastName: "",
            notes: "",
            timeStamp: "",
            directDownloadURL: "",
            folder: folder,
            dateAdded: Date().iso8601withFractionalSeconds
        )
        
    }
    
    func save() {
        savedListsPresenter.insertSavedItem(savedItem: defaultItem)
    }
    
    func setURL() {
        subscription = shareViewModel.$loadedItem.sink(receiveValue: {
            if let receivedValue = $0 {
                self.defaultItem = receivedValue
            }
        })
        shareViewModel.setURL(link, folder: folder)
    }
}
