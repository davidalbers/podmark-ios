import SwiftUI

struct FoldersView: View {
    @ObservedObject public var presenter = FoldersPresenter()
    @State private var showingAddAlert = false
    @State private var deletedFolder = ""
    @State private var showingDeleteAlert = false
    init() {
        UITableView.appearance().backgroundColor = UIColor(Color("background"))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack {
                    ForEach (presenter.folders, id: \.self) { item in
                        NavigationLink(destination: SavedListView(folderName: item)) {
                            VStack {
                                Text(item).font(.headline).accentColor(Color("text")).fullSizeFrame(alignment: .leading)
                                Rectangle().fullWidthFrame(maxHeight: 1, alignment: .leading).foregroundColor(Color("divider"))
                            }
                            .padding(6)
                            .fullSizeFrame(alignment: .leading)
                            .modifier(SwipeToDeleteRow(deleteAction: {
                                deletedFolder = item
                                showingDeleteAlert = true
                            }))
                        }
                    }
                }
            }
            .navigationBarTitle(Text("Folders"))
            .navigationBarItems(trailing: Button(action: {
                self.showingAddAlert = true
            }, label: {
                Image(systemName: "plus").resizable()
                    .frame(width: 18, height: 18)
            }))
        }.alert(isPresented: $showingAddAlert, TextAlert(
            title: "Add a folder",
            placeholder: "Folder name",
            cancel: "Cancel",
            action: { enteredText in
                presenter.addFolder(folderName: enteredText)
            }
        ))
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Delete \(deletedFolder)?"),
                primaryButton: .default(Text("Cancel")),
                secondaryButton: .destructive(Text("Delete"), action: { presenter.deleteFolder(deletedFolder) })
            )
        }
        .edgesIgnoringSafeArea(.all)
        .accentColor(Color("tint"))
    }
    
}
