import SwiftUI
import URLImage

struct ShareView: View {
    @ObservedObject public var shareViewModel = ShareViewModel()
    var dismissAction: (() -> Void)
    var cancelAction: (() -> Void)
    var disappearAction: (() -> Void)

    var body: some View {
        NavigationView {
            Form {
                if let item = shareViewModel.loadedItem {
                    Section {
                        SavedItemDetails(item: item)
                    }
                } else {
                    Text("Loading...")
                }
            }
            .navigationBarTitle("Save")
            .navigationBarItems(
                leading: Button(action: self.cancelAction, label: {
                    Text("Cancel")
                }),
                trailing: Button(action: self.dismissAction, label: {
                    Text("Done")
                })
            )
        }.onDisappear(perform: {
            disappearAction()
        })
    }
}

