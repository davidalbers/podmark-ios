import SwiftUI

/// Mimics the delete functionality in a list since a LazyVStack in iOS 14 does not support that.
/// Wraps a View with a gesture that will show a delete button when swiped vertically. deleteAction is invoked on button tap.
/// Alternatively, if the user swipes > 50% of the screen, deleteAction will also be invoked.
struct SwipeToDeleteRow: ViewModifier {
    // action to perform on delete
    var deleteAction: () -> Void
    // width of the delete button. height == height of content
    private let width : CGFloat = 50
    // offset of content
    @State private var offset : CGFloat = 0
    // true if the delete button will stay visible when the user stops dragging
    @State private var isSwiped : Bool = false

    public func body(content: Content) -> some View {
        ZStack(alignment: .trailing) {
            content
            
            // This is the "delete" button. You could put something else here as long as you use
            // contentShape, onTapGesture, and offset extensions
            HStack {
                Image(systemName: "trash")
                    .resizable()
                    .frame(width: 18, height: 24, alignment: .center)
                    .foregroundColor(Color.white)
                    .padding(.leading, 16)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
            .background(Color.red)
            .padding(.bottom, 5)
            .contentShape(Rectangle())
            .onTapGesture(perform: deleteAction)
            .offset(x: UIScreen.main.bounds.width)
        }
        .offset(x: offset)
        .contentShape(Rectangle())
        .gesture(DragGesture().onChanged(onChanged(value:)).onEnded(onEnd(value:)))
    }
    
    func onChanged(value: DragGesture.Value){
        if value.translation.width.magnitude > value.translation.height.magnitude && value.translation.width < 0 {
            if isSwiped {
                // show the full width of the button when "swiped"
                offset = value.translation.width - width
            } else {
                // offset the content to match the drag translation
                offset = value.translation.width
            }
        }
    }
    
    func onEnd(value: DragGesture.Value){
        withAnimation(.easeOut) {
            if value.translation.width < 0 {
                if -value.translation.width > UIScreen.main.bounds.width / 2 {
                    // user dragged > 50% of the screen delete
                    deleteAction()
                }
                else if -offset > width {
                    // user dragged enough to show the button, show it when they stop dragging
                    isSwiped = true
                    offset = -width
                }
                else {
                    // user did not drag enough, pop the button off the screen
                    isSwiped = false
                    offset = 0
                }
            }
            else{
                // user swiped right, pop the button off the screen
                isSwiped = false
                offset = 0
            }
        }
    }
}
