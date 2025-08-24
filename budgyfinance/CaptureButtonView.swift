import SwiftUI
import FirebaseFirestore
import FirebaseAuth

// Import GlassmorphismBackground from HomeView

// MARK: - Glassmorphism Background (using from HomeView.swift)

struct CaptureButtonView: View {
    @EnvironmentObject var firestoreManager: FirestoreManager
    @State private var showImagePicker = false
    @State private var sourceType: CameraView.SourceType = .camera
    @State private var receiptData: Receipt?
    @State private var isProcessing = false
    @StateObject private var imageCaptureManager = ImageCaptureManager()
    @State private var selectedImage: UIImage? // Keep for compatibility with pickers
    @State private var showEditReceipt = false
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var currentError: AppError?
    @State private var processingMessage = "Processing receipt..."
    @State private var showProcessingSteps = false
    @State private var currentStep = 0

    
    let processingSteps = [
        "Analyzing receipt image...",
        "Extracting text and data...",
        "Categorizing items...",
        "Saving to your account..."
    ]

    var body: some View {
        NavigationView {
            ZStack {
                // Animated gradient background
                GlassmorphismBackground()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header Section
                        GlassmorphicCaptureHeader()
                        
                        // Action Buttons
                        GlassmorphicActionButtons(
                            onCameraTap: {
                                sourceType = .camera
                                showImagePicker = true
                            },
                            onGalleryTap: {
                                sourceType = .photoLibrary
                                showImagePicker = true
                            }
                        )
                        
                        // Processing Section
                        if isProcessing {
                            GlassmorphicProcessingView(
                                processingMessage: processingMessage,
                                showProcessingSteps: showProcessingSteps,
                                processingSteps: processingSteps,
                                currentStep: currentStep
                            )
                        }
                        
                        // Tips Section
                        GlassmorphicTipsSection()
                        
                        Spacer(minLength: 30)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 20)
                }
            }
            .sheet(isPresented: $showImagePicker) {
                presentImagePicker()
            }
            .sheet(isPresented: $showEditReceipt) {
                if let receipt = receiptData {
                    EditReceiptView(receipt: receipt, onSave: { updatedReceipt in
                        self.receiptData = updatedReceipt
                        print("Receipt updated and saved")
                        self.showEditReceipt = false
                        self.receiptData = nil
                        self.showSuccessAlert = true
                    }, onCancel: {
                        print("Edit cancelled")
                        self.showEditReceipt = false
                        self.receiptData = nil
                    })
                }
            }
            .fullScreenCover(isPresented: $imageCaptureManager.showImageConfirmation) {
                Group {
                    let _ = print("🖼️ FullScreenCover is being rendered...")
                    let _ = print("🖼️ Manager selectedImage status: \(imageCaptureManager.selectedImage != nil ? "NOT NIL (\(imageCaptureManager.selectedImage!.size))" : "NIL")")
                    
                    if let image = imageCaptureManager.selectedImage {
                        let _ = print("🖼️ FullScreenCover: Using manager image with size: \(image.size)")
                        ImageConfirmationView(
                            selectedImage: image,
                            onConfirm: {
                                print("✅ User confirmed image processing")
                                imageCaptureManager.hideConfirmation()
                                processImage()
                            },
                            onCancel: {
                                print("❌ User cancelled image - going back to gallery")
                                imageCaptureManager.clearImage()
                                selectedImage = nil
                                showImagePicker = true
                            },
                            onRetake: {
                                print("📸 User wants to retake photo")
                                imageCaptureManager.clearImage()
                                selectedImage = nil
                                sourceType = .camera
                                showImagePicker = true
                            }
                        )
                    } else {
                        let _ = print("🚨 FullScreenCover: Manager selectedImage is nil!")
                        VStack {
                            Text("No image available")
                                .foregroundColor(.white)
                                .font(.headline)
                            
                            Text("Manager image is nil")
                                .foregroundColor(.yellow)
                                .font(.caption)
                            
                            Button("Close") {
                                imageCaptureManager.hideConfirmation()
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.red.opacity(0.8))
                    }
                }
            }
            .alert("Receipt Saved!", isPresented: $showSuccessAlert) {
                Button("OK") {
                    showSuccessAlert = false
                }
            } message: {
                Text("Your receipt has been successfully processed and saved to your account.")
            }
            .alert("Error", isPresented: $showErrorAlert) {
                if let error = currentError, error.isRetryable {
                    Button("Try Again") {
                        showErrorAlert = false
                        if selectedImage != nil {
                            processImage()
                        }
                    }
                    Button("Cancel", role: .cancel) {
                        showErrorAlert = false
                        resetProcessingState()
                    }
                } else {
                    Button("OK") {
                        showErrorAlert = false
                        resetProcessingState()
                    }
                }
            } message: {
                Text(currentError?.localizedDescription ?? "An unexpected error occurred.")
            }

        }
    }

    private func presentImagePicker() -> some View {
        if sourceType == .photoLibrary {
            print("Presenting CustomImagePicker")
            return AnyView(CustomImagePicker(selectedImage: $selectedImage)
                .onDisappear {
                    print("📷 Image picker dismissed")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if let image = selectedImage {
                            print("📷 Image selected from gallery, size: \(image.size)")
                            imageCaptureManager.setImage(image)
                        } else {
                            print("📷 No image was selected from gallery")
                        }
                    }
                })
        } else {
            print("Presenting CameraView")
            return AnyView(CameraView(sourceType: $sourceType, selectedImage: $selectedImage)
                .onDisappear {
                    print("📸 CameraView dismissed")
                    if let image = selectedImage {
                        print("📸 Image captured from camera, size: \(image.size)")
                        imageCaptureManager.setImage(image)
                    } else {
                        print("📸 No image was captured from camera")
                    }
                })
        }
    }

    private func processImage() {
        guard let image = imageCaptureManager.selectedImage else {
            print("No image selected")
            return
        }
        
        print("Image selected")
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert image to data")
            return
        }
        
        print("Starting processing")
        isProcessing = true
        showProcessingSteps = true
        currentStep = 0
        
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User is not logged in. Cannot process receipt.")
            currentError = .authenticationFailed
            showErrorAlert = true
            isProcessing = false
            showProcessingSteps = false
            return
        }

        // Simulate processing steps
        simulateProcessingSteps()
        
        BackendReceiptProcessor.processImage(imageData, forUser: userId) { result in
            DispatchQueue.main.async {
                isProcessing = false
                showProcessingSteps = false
                
                switch result {
                case .success(let receipt):
                    self.receiptData = receipt
                    print("Receipt processed successfully!")
                    // Show edit receipt overlay immediately
                    self.showEditReceipt = true
                    
                case .failure(let error):
                    print("Failed to process receipt: \(error.localizedDescription)")
                    
                    // Handle specific backend errors
                    switch error {
                    case .apiQuotaExceeded:
                        // TODO: Show subscription/upgrade prompt
                        print("💰 User quota exceeded - show upgrade prompt")
                    case .authenticationFailed:
                        // TODO: Re-authenticate user
                        print("🔐 Authentication failed - redirect to login")
                    case .noInternetConnection:
                        print("📡 No internet connection")
                    case .serverError(let message):
                        print("🏥 Server error: \(message)")
                    default:
                        print("❌ General error: \(error.localizedDescription)")
                    }
                    
                    self.currentError = error
                    self.showErrorAlert = true
                }
            }
        }
    }
    
    private func resetProcessingState() {
        print("🔄 resetProcessingState() called - clearing all images!")
        print("🔄 Call stack: \(Thread.callStackSymbols.prefix(3))")
        isProcessing = false
        showProcessingSteps = false
        imageCaptureManager.clearImage()
        selectedImage = nil
        currentStep = 0
        processingMessage = "Processing receipt..."
    }
    
    private func simulateProcessingSteps() {
        for (index, step) in processingSteps.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 1.5) {
                if isProcessing {
                    currentStep = index
                    processingMessage = step
                }
            }
        }
    }
}

// MARK: - Glassmorphic Components

// MARK: - Glassmorphic Capture Header
struct GlassmorphicCaptureHeader: View {
    var body: some View {
        VStack(spacing: 20) {
            // Camera icon with glassmorphic background
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 100, height: 100)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
            }
            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            
            VStack(spacing: 12) {
                Text("Scan Receipts")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Capture or upload receipts to automatically extract and categorize your expenses")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
        }
        .padding(.top, 20)
    }
}

// MARK: - Glassmorphic Action Buttons
struct GlassmorphicActionButtons: View {
    let onCameraTap: () -> Void
    let onGalleryTap: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Camera Button
            Button(action: onCameraTap) {
                HStack(spacing: 16) {
                    Image(systemName: "camera.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                    
                    Text("Take Photo")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                )
                .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 8)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Gallery Button
            Button(action: onGalleryTap) {
                HStack(spacing: 16) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.title2)
                        .foregroundColor(.white)
                    
                    Text("Choose from Gallery")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                )
                .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 8)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Glassmorphic Processing View
struct GlassmorphicProcessingView: View {
    let processingMessage: String
    let showProcessingSteps: Bool
    let processingSteps: [String]
    let currentStep: Int
    
    var body: some View {
        VStack(spacing: 24) {
            // Processing Animation
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 8)
                    .frame(width: 100, height: 100)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: true)
                
                Image(systemName: "doc.text.viewfinder")
                    .font(.title)
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 16) {
                Text(processingMessage)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                if showProcessingSteps {
                    VStack(spacing: 8) {
                        ForEach(0..<processingSteps.count, id: \.self) { index in
                            HStack(spacing: 12) {
                                Image(systemName: index <= currentStep ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(index <= currentStep ? .green : .white.opacity(0.6))
                                    .font(.caption)
                                
                                Text(processingSteps[index])
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Spacer()
                            }
                        }
                    }
                    .padding(.top, 8)
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
        .padding(.horizontal, 20)
    }
}

// MARK: - Glassmorphic Tips Section
struct GlassmorphicTipsSection: View {
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tips for Best Results")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("Follow these guidelines for optimal receipt scanning")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                // Tips icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.orange.opacity(0.3), Color.yellow.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                    
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.white)
                        .font(.title2)
                }
            }
            
            VStack(spacing: 12) {
                GlassmorphicTipRow(icon: "light.max", text: "Ensure good lighting for clear images")
                GlassmorphicTipRow(icon: "rectangle.3.group", text: "Include the entire receipt in the frame")
                GlassmorphicTipRow(icon: "textformat", text: "Make sure text is readable and not blurry")
                GlassmorphicTipRow(icon: "checkmark.shield", text: "Verify extracted data before saving")
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
        .padding(.horizontal, 20)
    }
}

// MARK: - Glassmorphic Tip Row
struct GlassmorphicTipRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// Legacy TipRow struct removed - using GlassmorphicTipRow instead
