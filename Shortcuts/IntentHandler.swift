import Intents
import Combine

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        if intent is AddIntent {
            return AddIntentHandler()
        } else if intent is ExportIntent {
            return ExportFileIntentHandler()
        } else {
            fatalError("Unhandled Intent error : \(intent)")
        }
    }
}

class ExportFileIntentHandler: NSObject, ExportIntentHandling {
    private var db = SavedListsDB()
    private var shareOptionsBuilder = ShareOptionsBuilder()
    func handle(intent: ExportIntent, completion: @escaping (ExportIntentResponse) -> Void) {
        let folders = db.openFolder(folderName: intent.folderName ?? "Favorites")
        var exportType = ShareOptionsBuilder.ShareType.text
        switch intent.exportType {
        case ExportTypes.rss:
            exportType = ShareOptionsBuilder.ShareType.rss
        case ExportTypes.json:
            exportType = ShareOptionsBuilder.ShareType.json
        default:
            exportType = ShareOptionsBuilder.ShareType.text
        }
        let result = shareOptionsBuilder.getShareDataAsString(type: exportType, items: folders)
        let response = ExportIntentResponse(code: ExportIntentResponseCode.success, userActivity: nil)
        response.outputString = result
        completion(response)
    }
    
    
}

class AddIntentHandler: NSObject, AddIntentHandling {
    private var db = SavedListsDB()
    private var shareViewModel = ShareViewModel()
    private var subscription: AnyCancellable? = nil

    func handle(intent: AddIntent, completion: @escaping (AddIntentResponse) -> Void) {
        if (intent.autofill ?? 0 == 1) {
            subscription = shareViewModel.$loadedItem.sink(receiveValue: { v in
                if let unw = v {
                    self.db.insertSavedItem(savedItem: unw)
                    completion(AddIntentResponse())
                }
            })
            shareViewModel.setURL(intent.url ?? "", folder: intent.folder ?? "Favorites", notes: intent.notes ?? "")
        } else {
            let savedItem = SavedItem(id: UUID().uuidString, sharedURL: intent.url ?? "", imageURL: intent.imageURL ?? "", title: intent.title ?? "", podcastName: intent.name ?? "", notes: intent.notes ?? "", timeStamp: intent.timestamp ?? "", directDownloadURL: intent.downloadLink ?? "", folder: intent.folder ?? "", dateAdded: Date().iso8601withFractionalSeconds)
            db.insertSavedItem(savedItem: savedItem)
            completion(AddIntentResponse())
        }
    }
}
