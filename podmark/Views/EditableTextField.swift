import SwiftUI

struct EditableTextField: View {
    var title: String
    var text: Binding<String>
    var onSaved: () -> Void

    var body: some View {
        TextField(title, text: text, onEditingChanged: { editing in
            if !editing {
                onSaved()
            }
        }).modifier(ClearButton(text: text, onSaved: onSaved))
    }
}

struct ClearButton: ViewModifier {
    @Binding var text: String
    var onSaved: () -> Void

    public func body(content: Content) -> some View {
        HStack {
            content
            if !text.isEmpty {
                Button(action: {}) {
                    Image(systemName: "xmark.circle.fill")
                }
                .padding(.trailing, 8)
                .onTapGesture {
                    // Have to use this rather than Button.action. Taps on a whole row
                    // in a form sometimes trigger action but not the tap gesture
                    self.text = ""
                    onSaved()
                }
            }
        }
    }
}
