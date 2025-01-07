import SwiftUI

struct CustomTextView: View {
    @Binding var text: String
    let placeholder: String
    let keyboardType: UIKeyboardType
    let autocapitalization: TextInputAutocapitalization
    
    var body: some View {
        TextField(placeholder, text: $text)
            .keyboardType(keyboardType)
            .textInputAutocapitalization(.none)
            .textFieldStyle(RoundedBorderTextFieldStyle())
    }
}
