import Foundation
import SwiftUI

struct ShareOptionsBuilder {
    public enum ShareType: String, CaseIterable {
        case text = "Text"
        case json = "JSON"
        case rss = "RSS"
    }
    
    func getButtons(action: @escaping (ShareType) -> Void) -> [ActionSheet.Button] {
        var buttons = [ActionSheet.Button]()
        ShareOptionsBuilder.ShareType.allCases.forEach { type in
            buttons.append(.default(Text(type.rawValue)) {
                action(type)
            })
        }

        buttons.append(.cancel())
        return buttons
    }
    
    func getAlertControllerButtons(action: @escaping (ShareType) -> Void) -> [UIAlertAction] {
        var buttons = [UIAlertAction]()
        ShareOptionsBuilder.ShareType.allCases.forEach { type in
            buttons.append(UIAlertAction(title: type.rawValue, style: .default , handler:{ (UIAlertAction) in
                action(type)
            }))
        }

        buttons.append(UIAlertAction(title: "Cancel", style: .cancel))
        return buttons
    }
    
    func getShareData(type: ShareType, items: [SavedItem]) -> Any {
        switch type {
        case ShareType.text:
            return getText(items: items)
        case ShareType.json:
            return getJson(items: items)
        case ShareType.rss:
            return getRSSFolder(items: items)
        }
    }
    
    func getShareDataAsString(type: ShareType, items: [SavedItem]) -> String {
        switch type {
        case ShareType.text:
            return getText(items: items)
        case ShareType.json:
            return getJson(items: items)
        case ShareType.rss:
            return getRSS(items: items)
        }
    }
    
    private func getRSS(items: [SavedItem]) -> String {
        let folderName = items.first?.folder ?? "Podmark"
        return items.map { item in
            "<item><title>\(item.title): \(item.podcastName)</title>\n" +
            "<content:encoded>From your \(folderName) folder</content:encoded>\n" +
            "<link>\(item.sharedURL)</link>\n" +
            "<image><url>\(item.imageURL)</url></image>\n" +
            "<description>\(item.notes)</description>\n" +
            "<enclosure url=\"\(item.directDownloadURL)\" length=\"0\" type=\"audio/mpeg\"/>\n</item>"
        }.joined(separator: "\n")
    }
    
    private func getRSSFolder(items: [SavedItem]) -> Any {
        let folderName = items.first?.folder ?? "Podmark"
        return getShareableFile(fileContents: "<?xml version=\"1.0\" encoding=\"UTF-8\" ?><rss version=\"2.0\"><channel><title>\(folderName)</title>" + getRSS(items: items) + "</channel></rss>")
    }
    
    
    private func getText(items: [SavedItem]) -> String {
        items.map { item in
            "title: \(item.title)\n" +
            "podcast name: \(item.podcastName)\n" +
            "folder: \(item.folder)\n" +
            "time stamp: \(item.timeStamp)\n" +
            "shared URL: \(item.sharedURL)\n" +
            "image URL: \(item.imageURL)\n" +
            "notes: \(item.notes)\n" +
            "direct download URL: \(item.directDownloadURL)\n"
        }.joined(separator: "\n")
    }
    
    private func getJson(items: [SavedItem]) -> String {
        let jsonEncoder = JSONEncoder()
        let itemsJSON = items.map { item in
            if let encoded = try? jsonEncoder.encode(item) {
                return String(data: encoded, encoding: String.Encoding.utf8) ?? ""
            } else { return "" }
        }.joined(separator: ",\n")
        return "{\"items\": [\(itemsJSON)]}"
    }
    
    private func getShareableFile(fileContents: String) -> Any {
        let filename = getDocumentsDirectory().appendingPathComponent("file.rss")

        do {
            try fileContents.write(toFile: filename, atomically: true, encoding: String.Encoding.utf8)
            return NSURL(fileURLWithPath: filename)
        } catch {
            print("cannot write file")
            return ""
        }
    }

    private func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory as NSString
    }
}
