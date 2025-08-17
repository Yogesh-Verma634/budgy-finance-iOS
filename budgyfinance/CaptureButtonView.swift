import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct CaptureButtonView: View {
    @State private var showImagePicker = false
    @State private var sourceType: CameraView.SourceType = .camera
    @State private var receiptData: Receipt?
    @State private var isProcessing = false
    @State private var selectedImage: UIImage?
    @State private var showEditReceipt = false
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
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
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Header Section
                        VStack(spacing: 16) {
                            Image(systemName: "camera.viewfinder")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)
                            
                            Text("Scan Receipts")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("Capture or upload receipts to automatically extract and categorize your expenses")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.top, 20)
                        
                        // Action Buttons
                        VStack(spacing: 16) {
                            // Camera Button
                            Button(action: {
                                sourceType = .camera
                                showImagePicker = true
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "camera.fill")
                                        .font(.title2)
                                    Text("Take Photo")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                                .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            
                            // Gallery Button
                            Button(action: {
                                sourceType = .photoLibrary
                                showImagePicker = true
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "photo.on.rectangle")
                                        .font(.title2)
                                    Text("Choose from Gallery")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.white)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.blue, lineWidth: 2)
                                )
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Processing Section
                        if isProcessing {
                            VStack(spacing: 20) {
                                // Processing Animation
                                ZStack {
                                    Circle()
                                        .stroke(Color.blue.opacity(0.2), lineWidth: 8)
                                        .frame(width: 80, height: 80)
                                    
                                    Circle()
                                        .trim(from: 0, to: 0.7)
                                        .stroke(Color.blue, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                                        .frame(width: 80, height: 80)
                                        .rotationEffect(.degrees(-90))
                                        .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isProcessing)
                                    
                                    Image(systemName: "doc.text.viewfinder")
                                        .font(.title)
                                        .foregroundColor(.blue)
                                }
                                
                                VStack(spacing: 8) {
                                    Text(processingMessage)
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    
                                    if showProcessingSteps {
                                        VStack(spacing: 4) {
                                            ForEach(0..<processingSteps.count, id: \.self) { index in
                                                HStack {
                                                    Image(systemName: index <= currentStep ? "checkmark.circle.fill" : "circle")
                                                        .foregroundColor(index <= currentStep ? .green : .gray)
                                                        .font(.caption)
                                                    
                                                    Text(processingSteps[index])
                                                        .font(.caption)
                                                        .foregroundColor(index <= currentStep ? .primary : .secondary)
                                                    
                                                    Spacer()
                                                }
                                            }
                                        }
                                        .padding(.top, 8)
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(20)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                            .padding(.horizontal, 24)
                        }
                        
                        // Tips Section
                        VStack(spacing: 16) {
                            Text("Tips for Best Results")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            VStack(spacing: 12) {
                                TipRow(icon: "light.max", text: "Ensure good lighting for clear images")
                                TipRow(icon: "rectangle.3.group", text: "Include the entire receipt in the frame")
                                TipRow(icon: "textformat", text: "Make sure text is readable and not blurry")
                                TipRow(icon: "checkmark.shield", text: "Verify extracted data before saving")
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        .padding(.horizontal, 24)
                        
                        Spacer(minLength: 50)
                    }
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
            .alert("Receipt Saved!", isPresented: $showSuccessAlert) {
                Button("OK") {
                    showSuccessAlert = false
                }
            } message: {
                Text("Your receipt has been successfully processed and saved to your account.")
            }
            .alert("Processing Failed", isPresented: $showErrorAlert) {
                Button("Try Again") {
                    showErrorAlert = false
                    // Reset processing state
                    isProcessing = false
                    showProcessingSteps = false
                    selectedImage = nil
                }
                Button("Cancel", role: .cancel) {
                    showErrorAlert = false
                    isProcessing = false
                    showProcessingSteps = false
                    selectedImage = nil
                }
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func presentImagePicker() -> some View {
        if sourceType == .photoLibrary {
            print("Presenting CustomImagePicker")
            return AnyView(CustomImagePicker(selectedImage: $selectedImage)
                .onDisappear {
                    print("Image picker dismissed")
                    if selectedImage != nil {
                        print("Image selected, starting processing")
                        processSelectedImage()
                    }
                })
        } else {
            print("Presenting CameraView")
            return AnyView(CameraView(sourceType: $sourceType, selectedImage: $selectedImage)
                .onDisappear {
                    print("CameraView dismissed")
                    if selectedImage != nil {
                        print("Image selected, starting processing")
                        processSelectedImage()
                    }
                })
        }
    }

    private func processSelectedImage() {
        guard let image = selectedImage else {
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
            isProcessing = false
            return
        }

        // Simulate processing steps
        simulateProcessingSteps()
        
        ReceiptProcessor.processImage(imageData, forUser: userId) { receiptData in
            DispatchQueue.main.async {
                isProcessing = false
                showProcessingSteps = false
                if var receipt = receiptData {
                    receipt.scannedTime = Date()
                    self.receiptData = receipt
                    print("Receipt processed successfully!")
                    // Show edit receipt overlay immediately
                    self.showEditReceipt = true
                } else {
                    print("Failed to process receipt.")
                    // Show error alert
                    self.showErrorAlert = true
                    self.errorMessage = "Failed to process receipt. Please try again later."
                }
            }
        }
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

struct TipRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}
