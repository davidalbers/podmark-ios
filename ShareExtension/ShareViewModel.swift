
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
        timeStamp = getTimeStamp(urlString: urlString)
        AF.request(urlString).responseString { responseString in
            let urlHTML = (try? responseString.result.get()) ?? ""
            let id = self.parseDataFromHTML(urlHTML)
            if id.isEmpty {
                self.getLinkedData(html: urlHTML)
            } else {
                self.getItunesData(id: id)
            }
        }
    }
    
    func cancel() {
        savedListsPresenter.deleteSavedItem(id: sharedURL)
    }

    private func getTimeStamp(urlString: String) -> String {
        let colonBased = getColonTimeStamp(urlString: urlString)
        if !colonBased.isEmpty {
            return colonBased
        } else {
            return getSecondsTimeStamp(urlString: urlString)
        }
    }

    // e.g. t=3600
    private func getSecondsTimeStamp(urlString: String) -> String {
        let totalSeconds = Int(urlString.findFirstGroupInRegex(regexString: #"t=(\d+)"#)) ?? 0
        let seconds = totalSeconds % 3600 % 60
        let minutes = totalSeconds % 3600 / 60
        let hours = totalSeconds / 3600
        if minutes == 0 && hours == 0 && seconds == 0 {
            return ""
        } else if hours == 0 {
            return String(format: "%02d:%02d", minutes, seconds)
        } else {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
    }

    // e.g. 12:34
    private func getColonTimeStamp(urlString: String) -> String {
        return urlString.findFirstGroupInRegex(regexString: #"(\d+:\d+)$"#)
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

    private func getLinkedData(html: String) {
        // <script type="application/ld+json">
        let linkedData = html.findFirstGroupInRegex(regexString: #"<script type="application/ld\+json">(([^<]|\n)*)</script>"#)
        print(linkedData)
        let decoder = JSONDecoder()
        if let linkedDataData = linkedData.data(using: .utf8){
            let decoded: LinkedData? = try? decoder.decode(LinkedData.self, from: linkedDataData)
            let name = decoded?.name

            self.podcastName = name ?? ""
            self.title = decoded?.partOfSeries.name ?? ""
            self.imageURL = decoded?.image ?? ""
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

struct LinkedData: Codable {
    let name: String
    let image: String
    let partOfSeries: LinkedDataSeries
}

struct LinkedDataSeries: Codable {
    let name: String
}
