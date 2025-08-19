import SwiftUI

struct ImageConfirmationView: View {
    let selectedImage: UIImage
    let onConfirm: () -> Void
    let onCancel: () -> Void
    let onRetake: () -> Void
    
    @State private var imageScale: CGFloat = 1.0
    @State private var imageOffset: CGSize = .zero
    @State private var showImageDetail = false

    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea(.all)
            
            VStack(spacing: 0) {
                // Modern Header
                headerView
                
                // Image Preview with Modern Styling
                imagePreviewSection
                
                // Modern Action Bar
                actionBarSection
            }
        }
        .onAppear {
            print("🖼️ ImageConfirmationView appeared with image size: \(selectedImage.size)")
        }
        .sheet(isPresented: $showImageDetail) {
            ImageDetailView(image: selectedImage)
        }
    }
    
    private var headerView: some View {
            HStack {
            // Cancel Button
            Button(action: onCancel) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .fontWeight(.medium)
                    Text("Cancel")
                        .font(.body)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
            }
            
            Spacer()
            
            // Title
            Text("Preview")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Spacer()
            
            // Info Button
            Button(action: { showImageDetail = true }) {
                Image(systemName: "info.circle")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Color.black.opacity(0.7)
                .background(.ultraThinMaterial, in: Rectangle())
        )
    }
    
    private var imagePreviewSection: some View {
        GeometryReader { geometry in
            ZStack {
                // Subtle gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(0.9),
                        Color.black.opacity(0.7)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // Image with modern styling
                Image(uiImage: selectedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(imageScale)
                    .offset(imageOffset)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    .gesture(imageGestures)
                    .onTapGesture(count: 2) {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            if imageScale > 1.0 {
                                imageScale = 1.0
                                imageOffset = .zero
                            } else {
                                imageScale = 2.0
                            }
                        }
                    }
                
                // Quality indicator overlay
                VStack {
                    HStack {
                        Spacer()
                        qualityIndicator
                            .padding(.top, 20)
                            .padding(.trailing, 20)
                    }
                    Spacer()
                }
                
                // Gesture hints
                VStack {
                    Spacer()
                    gestureHints
                        .padding(.bottom, 20)
                }
            }
        }
    }
    
    private var imageGestures: some Gesture {
        SimultaneousGesture(
            MagnificationGesture()
                .onChanged { value in
                    imageScale = max(0.5, min(value, 3.0))
                },
            DragGesture()
                .onChanged { value in
                    imageOffset = value.translation
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        imageOffset = .zero
                    }
                }
        )
    }
    
    private var qualityIndicator: some View {
        let quality = analyzeImageQuality(selectedImage)
        
        return HStack(spacing: 8) {
            Image(systemName: quality.icon)
                .font(.caption)
                .foregroundColor(quality.color)
            
            Text(quality.text)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(quality.color)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Color.black.opacity(0.6)
                .background(.ultraThinMaterial, in: Capsule())
        )
        .clipShape(Capsule())
    }
    
    private var gestureHints: some View {
        HStack(spacing: 16) {
            Label("Pinch to zoom", systemImage: "hand.pinch")
            Label("Double tap to reset", systemImage: "hand.tap")
        }
        .font(.caption2)
        .foregroundColor(.white.opacity(0.6))
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Color.black.opacity(0.4)
                .background(.ultraThinMaterial, in: Capsule())
        )
        .clipShape(Capsule())
    }
    
    private var actionBarSection: some View {
        VStack(spacing: 20) {
            // Tips section
            modernTipsSection
            
            // Action buttons
            HStack(spacing: 16) {
                // Retake button
                modernButton(
                    title: "Retake",
                    icon: "camera.fill",
                    style: .secondary,
                    action: onRetake
                )
                
                // Process button
                modernButton(
                    title: "Use Photo",
                    icon: "checkmark",
                    style: .primary,
                    action: onConfirm
                )
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 20)
        .background(
            Color.black.opacity(0.8)
                .background(.ultraThinMaterial, in: Rectangle())
        )
    }
    
    private var modernTipsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                    .font(.caption)
                
                Text("Tips for better results")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            VStack(spacing: 8) {
                modernTipRow(icon: "viewfinder", text: "Ensure receipt is fully visible", color: .green)
                modernTipRow(icon: "textformat", text: "Check text is clear and readable", color: .blue)
                modernTipRow(icon: "sun.max", text: "Good lighting improves accuracy", color: .orange)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func modernTipRow(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundColor(color)
                .frame(width: 16)
            
            Text(text)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
        }
    }
    
    private func modernButton(title: String, icon: String, style: ButtonStyle, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(title)
                    .font(.body)
                    .fontWeight(.semibold)
            }
            .foregroundColor(style == .primary ? .black : .white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                Group {
                    if style == .primary {
                        LinearGradient(
                            gradient: Gradient(colors: [Color.white, Color.white.opacity(0.9)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    } else {
                        Color.white.opacity(0.15)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(style == .secondary ? Color.white.opacity(0.2) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(ModernButtonStyle())
    }
    
    private func analyzeImageQuality(_ image: UIImage) -> (icon: String, text: String, color: Color) {
        let size = image.size
        let area = size.width * size.height
        
        if area > 1_000_000 {
            return ("checkmark.circle.fill", "Excellent", .green)
        } else if area > 500_000 {
            return ("exclamationmark.circle.fill", "Good", .orange)
        } else {
            return ("xmark.circle.fill", "Fair", .red)
        }
    }
    
    enum ButtonStyle {
        case primary, secondary
    }
}

// MARK: - Button Styles
struct ModernButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct ImageDetailView: View {
    let image: UIImage
    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(scale)
                    .offset(offset)
                    .clipped()
                    .gesture(
                        SimultaneousGesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    scale = max(0.5, min(value, 5.0))
                                },
                            DragGesture()
                                .onChanged { value in
                                    offset = value.translation
                                }
                                .onEnded { _ in
                                    withAnimation(.spring()) {
                                        offset = .zero
                                    }
                                }
                        )
                    )
                    .onTapGesture(count: 2) {
                        withAnimation(.spring()) {
                            if scale > 1.0 {
                                scale = 1.0
                                offset = .zero
                            } else {
                                scale = 2.0
                            }
                        }
                    }
            }
            .navigationTitle("Receipt Image")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                .foregroundColor(.white)
                }
            }
        }
    }
}

#Preview {
    if let sampleImage = UIImage(systemName: "doc.text.viewfinder") {
        ImageConfirmationView(
            selectedImage: sampleImage,
            onConfirm: { print("Confirmed") },
            onCancel: { print("Cancelled") },
            onRetake: { print("Retake") }
        )
    }
}
