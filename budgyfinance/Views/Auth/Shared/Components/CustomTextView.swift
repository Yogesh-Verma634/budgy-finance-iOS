import SwiftUI

struct CustomTextView: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "envelope")
                .foregroundColor(.gray)
            TextField(placeholder, text: $text)
                .autocapitalization(.none)
                .disableAutocorrection(true)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
