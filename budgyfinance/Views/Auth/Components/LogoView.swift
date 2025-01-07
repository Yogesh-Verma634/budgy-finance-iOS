import SwiftUI

struct LogoView: View {
    var body: some View {
        VStack {
            Text("Budgy Finance")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Track Your Expenses")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
} 