import SwiftUI

struct SavedItemDetailsScreen: View {
    @ObservedObject public var presenter: SavedListItemPresenter
    @State private var showShareTypesSheet = false
    @State private var showShareSheet = false
    @State private var shareType = ShareOptionsBuilder.ShareType.text
    private var shareOptionsBuilder: ShareOptionsBuilder

    init(item: SavedItem) {
        self.presenter = SavedListItemPresenter(item: item)
        shareOptionsBuilder = ShareOptionsBuilder()
    }

    var body: some View {
        Form {
            Section(header: Text("Podcast info")) {
                SavedItemDetails(item: presenter.currentItem)
            }
            ItemAction(title: "Shared link", url: $presenter.currentItem.sharedURL) {
                presenter.save()
            }
            ItemAction(title: "Direct download link", url: $presenter.currentItem.directDownloadURL) {
                presenter.save()
            }
        }
        .navigationBarTitle("Saved item", displayMode: .inline)
        .navigationBarItems(trailing: Button(action: {
            self.showShareTypesSheet = true
        }, label: {
            Image(systemName: "square.and.arrow.up").resizable()
                .frame(width: 18, height: 24)
        })).actionSheet(isPresented: $showShareTypesSheet) {
            ActionSheet(title: Text("Share as..."), buttons: shareOptionsBuilder.getButtons { type in
                shareType = type
                showShareSheet = true
            })
        }.sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: [shareOptionsBuilder.getShareData(type: shareType, items: [presenter.currentItem])])
        }
    }
}
