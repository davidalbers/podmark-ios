import Foundation
import SQLite

struct SavedItem: Codable {
    var id: String
    var sharedURL: String
    var imageURL: String
    var title: String
    var podcastName: String
    var notes: String
    var timeStamp: String
    var directDownloadURL: String
    var folder: String
    var dateAdded: String
}

class SavedListsDB {
    var db: Connection? = nil
    let savedItems: Table
    let folders: Table
    let savedItemId = Expression<String>("savedItemId")
    let savedItemJson = Expression<String>("savedItemJson")
    let folderNameKey = Expression<String>("folderName")
    
    init() {
        let fileManager = FileManager.default
        let directory = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.podmark")
        let path = directory!.appendingPathComponent("db.sqlite3").path
        
        savedItems = Table("saved")
        folders = Table("folders")

        do {
            db = try Connection(path)
        } catch {
            print("error creating DB connection")
            return
        }
        
        do {
            try db?.run(savedItems.create(ifNotExists: true) { t in
                t.column(savedItemId, primaryKey: true)
                t.column(savedItemJson)
                t.column(folderNameKey)
            })
            try db?.run(folders.create(ifNotExists: true) { t in
                t.column(folderNameKey, primaryKey: true)
            })
        } catch {
          print("error creating DB")
        }
    }
    
    func addFolder(folderName: String) {
        do {
            try db?.run(
                folders.insert(
                    or: OnConflict.replace,
                    folderNameKey <- folderName
                )
            )
        } catch {
            print("error inserting")
        }
    }
    
    func deleteFolder(folderName: String) {
        do {
            let folderRow = folders.filter(folderNameKey == folderName)
            let matchedItems = savedItems.filter(folderNameKey == folderName)

            try db?.run(
                folderRow.delete()
            )
            try db?.run(
                matchedItems.delete()
            )
        } catch {
            print("error inserting")
        }
    }
    
    func getFolders() -> [String] {
        do {
            let dbRows = try db?.prepare(folders)
            return dbRows?.map { row in
                row[folderNameKey]
            } ?? []
        } catch {
            print("error reading")
            return []
        }
    }
    
    func deleteSavedItem(id: String) {
        do {
            let row = savedItems.filter(savedItemId == id)
            try db?.run(
                row.delete()
            )
        } catch {
            print("error deleting")
        }
    }
    
    func insertSavedItem(savedItem: SavedItem) {
        let jsonEncoder = JSONEncoder()
        guard let jsonData = try? jsonEncoder.encode(savedItem) else { return }
        let json = String(data: jsonData, encoding: String.Encoding.utf8) ?? ""
        
        do {
            try db?.run(
                savedItems.insert(
                    or: OnConflict.replace,
                    savedItemId <- savedItem.id,
                    savedItemJson <- json,
                    folderNameKey <- savedItem.folder
                )
            )
        } catch {
            print("error inserting")
        }
    }
    
    func openFolder(folderName: String) -> [SavedItem] {
        do {
            let jsonDecoder = JSONDecoder()
            let dbRows = try db?.prepare(savedItems)
            var values = [SavedItem]()
            dbRows?.forEach { row in
                if let data = row[savedItemJson].data(using: String.Encoding.utf8),
                   let decoded = try? jsonDecoder.decode(SavedItem.self, from: data) {
                        values.append(decoded)
                }
            }
            return values.filter { value in
                value.folder == folderName
            }
        } catch {
            print("error reading")
            return []
        }
    }
}
