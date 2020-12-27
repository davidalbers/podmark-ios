import SwiftUI

struct ManualAddItemView: View {
    @ObservedObject var presenter: ManualAddItemPresenter
    var dismissAction: () -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Podcast link")) {
                    EditableTextField(title: "URL", text: $presenter.link) {}
                    if presenter.showSetLinkButton {
                        Button(action: {
                            presenter.setURL()
                        }, label: {
                            Text("Autofill with this URL")
                        })
                    }
                }
                
                Section(header: Text("Podcast description")) {
                    SavedItemDetails(item: presenter.defaultItem)
                }
            }
            .navigationBarTitle("Add")
            .navigationBarItems(
                leading: Button(action: {
                    dismissAction()
                }, label: {
                    Text("Cancel")
                }),
                trailing: Button(action: {
                    presenter.save()
                    dismissAction()
                }, label: {
                    Text("Done")
                })
            )
        }.accentColor(Color("tint"))
    }
}

