import SwiftUI

struct ImageConfirmationView: View {
    let image: UIImage
    var onConfirm: () -> Void
    var onCancel: () -> Void

    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: 300)
                .padding()

            HStack {
                Button("Cancel") {
                    onCancel()
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)

                Button("Confirm") {
                    onConfirm()
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding()
    }
} 