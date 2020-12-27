import SwiftUI

struct ItemAction: View {
    var title: String
    var url: Binding<String>
    var onSaved: () -> Void
    @State var showShareSheet = false
    
    var body: some View {
        Section(header: Text(title)) {
            EditableTextField(title: "url", text: url) {
                onSaved()
            }.lineLimit(1)
        
            if let url = URL(string: url.wrappedValue) {
                Button("Open") {
                    UIApplication.shared.open(url)
                }
                Button("Share") {
                    showShareSheet = true
                }.sheet(isPresented: $showShareSheet) {
                    ShareSheet(activityItems: [url])
                }
            }
        }
    }
}
