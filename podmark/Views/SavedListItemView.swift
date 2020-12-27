import Foundation
import SwiftUI

struct SavedItemDetails: View {
    @ObservedObject public var presenter: SavedListItemPresenter

    init(item: SavedItem) {
        self.presenter = SavedListItemPresenter(item: item)
    }

    var body: some View {
        if !presenter.currentItem.imageURL.isEmpty {
            Section {
                HStack {
                    RoundedURLImage(url: presenter.currentItem.imageURL)
                        .frame(width: 96, height: 96, alignment: Alignment.center)
                        .padding(6)
                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
            }
        }
        SaveableTextField(title: "Episode title", text: $presenter.currentItem.title, presenter: presenter)

        SaveableTextField(title: "Podcast name", text: $presenter.currentItem.podcastName, presenter: presenter)
        
        SaveableTextField(title: "Timestamp", text: $presenter.currentItem.timeStamp, presenter: presenter)
        
        SaveableTextField(title: "Notes", text: $presenter.currentItem.notes, presenter: presenter)

        Section {
            Picker(selection: $presenter.folderIndex, label: Text("Folder")) {
                ForEach(0 ..< presenter.folders.count) {
                    Text(self.presenter.folders[$0])
                }
            }
        }
    }
    
    struct SaveableTextField: View {
        var title: String
        var text: Binding<String>
        var presenter: SavedListItemPresenter
        var body: some View {
            Section {
                EditableTextField(title: title, text: text) {
                    self.presenter.save()
                }
            }
        }
    }
}


