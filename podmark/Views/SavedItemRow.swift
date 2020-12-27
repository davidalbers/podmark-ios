import SwiftUI

struct SavedItemRow: View {
    var item: SavedItem
    
    var body: some View {
        VStack {
            HStack(alignment: VerticalAlignment.center, spacing: 6) {
                RoundedURLImage(url: item.imageURL).frame(width: 64, height: 64, alignment: Alignment.leading)
                VStack(alignment: HorizontalAlignment.leading, spacing: 6) {
                    Text(item.podcastName).font(.headline).accentColor(Color("text"))
                    if !item.title.isEmpty {
                        Text(item.title).font(.subheadline).accentColor(Color("text"))
                    }
                }
            }.fullSizeFrame(alignment: .leading)
            Rectangle().fullWidthFrame(maxHeight: 1, alignment: .leading).foregroundColor(Color("divider"))
        }.padding(.vertical, 6).padding(.horizontal, 12)
    }
}
