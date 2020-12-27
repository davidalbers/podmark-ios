import Foundation
import SwiftUI

extension View {
    public func fullWidthFrame(maxHeight: CGFloat, alignment: Alignment = .center) -> some View {
        return frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: maxHeight, alignment: alignment)
    }
    
    public func fullSizeFrame(alignment: Alignment = .center) -> some View {
        return fullWidthFrame(maxHeight: .infinity, alignment: alignment)
    }
}
