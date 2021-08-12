
import Foundation
import Alamofire

struct ITunesResponse: Decodable {
    let results: [ITunesResult]
}
struct ITunesResult: Decodable {
    let collectionName: String
    let artworkUrl600: String
}

class ShareViewModel: ObservableObject {
    private var title = ""
    private var podcastName = ""
    private var imageURL = ""
    private var notes = ""
    private var directDownloadLink = ""
    private var timeStamp = ""
    @Published var loadedItem: SavedItem? = nil
    private var sharedURL = ""
    private var savedListsPresenter = SavedListsDB()
    private var folder = ""
    
    func setURL(_ urlString: String, folder: String = "Favorites", notes: String = "") {
        sharedURL = urlString
        self.folder = folder
        self.notes = notes
        let k = urlString.findFirstGroupInRegex(regexString: #"(\d+:\d+)$"#)
        timeStamp = k
        AF.request(urlString).responseString { responseString in
            let urlHTML = (try? responseString.result.get()) ?? ""
            let id = self.parseDataFromHTML(urlHTML)
            self.getItunesData(id: id)
        }
    }
    
    func cancel() {
        savedListsPresenter.deleteSavedItem(id: sharedURL)
    }
    
    private func parseDataFromHTML(_ urlHTML: String) -> String {
        self.title = urlHTML.findFirstGroupInRegex(regexString: #"<title>([^<]*)<"#)
        self.directDownloadLink = urlHTML.findFirstGroupInRegex(regexString: #"(https://[^"]*.mp3[^"]*)"#)
        return urlHTML.findFirstGroupInRegex(regexString: #"apple.com.*/podcast/.*id(\d+)"#)
    }
    
    private func cleanUpTitle(_ titleFromHTML: String, podcastName: String) -> String {
        return titleFromHTML
            .removeSubstring("overcast")
            .removeSubstring("gimlet")
            .removeSubstring("on apple podcasts")
            .removeSubstring(podcastName)
            .trimmingCharactersRecursive(#"-—⁠–:|"#)
    }

    
    private func getItunesData(id: String) {
        AF.request("https://itunes.apple.com/lookup?id=\(id)").responseDecodable(of: ITunesResponse.self) { response in
            let iTunesResponse = (try? response.result.get())
            self.podcastName = iTunesResponse?.results.first?.collectionName.decodingHTMLEntities() ?? ""
            self.title = self.cleanUpTitle(self.title, podcastName: self.podcastName)
            self.imageURL = iTunesResponse?.results.first?.artworkUrl600 ?? ""
            let loadedItem = SavedItem(
                id: UUID().uuidString,
                sharedURL: self.sharedURL,
                imageURL: self.imageURL,
                title: self.title,
                podcastName: self.podcastName,
                notes: self.notes,
                timeStamp: self.timeStamp,
                directDownloadURL: self.directDownloadLink,
                folder: self.folder,
                dateAdded: Date().iso8601withFractionalSeconds
            )
            self.savedListsPresenter.insertSavedItem(savedItem: loadedItem)
            self.loadedItem = loadedItem
        }
    }
}
