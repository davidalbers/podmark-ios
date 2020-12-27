import SwiftUI
import URLImage

struct RoundedURLImage: View {
    var url: String
    var body: some View {
        if let url = URL.init(string: url) {
            URLImage(url) { image in
                image.image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color("border"), lineWidth: 1)
                    )
            }
        }
    }
}
