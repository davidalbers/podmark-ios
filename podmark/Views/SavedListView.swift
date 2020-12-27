import SwiftUI

struct SavedListView: View {
    @State private var showShareTypesSheet = false
    @State private var showShareSheet = false
    @State private var showSortSheet = false
    @State private var showAddDialog = false
    @State private var shareType = ShareOptionsBuilder.ShareType.text
    var shareOptionsBuilder = ShareOptionsBuilder()

    @ObservedObject public var presenter = SavedListsPresenter()
    var folderName: String
    
    var body: some View {
        VStack {
            if presenter.items.isEmpty {
                Text("Nothing here...\nClick the + or share from your favorite podcast app")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24).fullSizeFrame(alignment: .center)
            } else {
                ScrollView {
                    LazyVStack {
                        ForEach(presenter.items, id: \.id) { item in
                            NavigationLink(destination: SavedItemDetailsScreen(item: item)) {
                                SavedItemRow(item: item)
                                .modifier(SwipeToDeleteRow(deleteAction: {
                                    presenter.deleteSavedItem(id: item.id)
                                }))
                            }
                        }
                    }
                }
            }
        }
        .navigationBarTitle(Text(folderName))
        .navigationBarItems(trailing:
            HStack {
                Button(action: {
                    showAddDialog = true
                }, label: {
                    Image(systemName: "plus").resizable()
                        .frame(width: 24, height: 24)
                })
                .sheet(isPresented: $showAddDialog) {
                    ManualAddItemView(
                        presenter: ManualAddItemPresenter(folder: folderName),
                        dismissAction: {
                            showAddDialog = false
                            presenter.loadFolder(folderName: folderName)
                        }
                    )
                }
                
                Spacer(minLength: 24)
                Button(action: {
                    showSortSheet = true
                }, label: {
                    Image(systemName: "line.horizontal.3.decrease.circle").resizable()
                        .frame(width: 24, height: 24)
                }).sheet(isPresented: $showShareSheet) {
                    ShareSheet(activityItems: [shareOptionsBuilder.getShareData(type: shareType, items: presenter.items)])
                }.actionSheet(isPresented: $showSortSheet) {
                    ActionSheet(title: Text("Sort by..."), buttons: presenter.getSortButtons { type in
                        presenter.sort = type
                    })
                }
                Spacer(minLength: 24)
                Button(action: {
                    self.showShareTypesSheet = true
                }, label: {
                    Image(systemName: "square.and.arrow.up").resizable()
                        .frame(width: 18, height: 24)
                }).actionSheet(isPresented: $showShareTypesSheet) {
                    ActionSheet(title: Text("Share as..."), buttons: shareOptionsBuilder.getButtons { type in
                        shareType = type
                        showShareSheet = true
                    })
                }
            }
        )
        .onAppear(perform: {presenter.loadFolder(folderName: folderName)})
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            presenter.loadFolder(folderName: folderName)
        }
    }
}



