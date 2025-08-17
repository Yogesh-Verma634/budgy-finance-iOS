import SwiftUI

struct AppIconView: View {
    let size: CGFloat
    let showGlow: Bool
    
    init(size: CGFloat = 60, showGlow: Bool = true) {
        self.size = size
        self.showGlow = showGlow
    }
    
    var body: some View {
        ZStack {
            if showGlow {
                Circle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: size + 20, height: size + 20)
                    .blur(radius: 15)
            }
            
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.blue,
                            Color.purple.opacity(0.8)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
                .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
            
            Image(systemName: "wallet.pass.fill")
                .font(.system(size: size * 0.5, weight: .medium))
                .foregroundColor(.white)
        }
    }
}

struct AppLogoView: View {
    let showIcon: Bool
    let showTagline: Bool
    
    init(showIcon: Bool = true, showTagline: Bool = true) {
        self.showIcon = showIcon
        self.showTagline = showTagline
    }
    
    var body: some View {
        VStack(spacing: 16) {
            if showIcon {
                AppIconView(size: 80, showGlow: true)
            }
            
            VStack(spacing: 8) {
                Text("Budgy")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                if showTagline {
                    Text("Smart Finance Management")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        AppIconView(size: 60)
        AppIconView(size: 80)
        AppIconView(size: 100)
        
        Divider()
        
        AppLogoView()
    }
    .padding()
} 