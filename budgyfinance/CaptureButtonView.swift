import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct CaptureView: View {
    @State private var showImagePicker = false
    @State private var sourceType: CameraView.SourceType = .camera
    @State private var receiptData: Receipt?
    @State private var isProcessing = false
    @State private var selectedImage: UIImage?

    var body: some View {
        NavigationView {
            VStack {
                Button("Capture Receipt") {
                    sourceType = .camera
                    showImagePicker = true
                    print("Camera selected")
                }
                .padding()

                Button("Upload Receipt") {
                    sourceType = .photoLibrary
                    showImagePicker = true
                    print("Photo library selected")
                }
                .padding()
                
                if isProcessing {
                    ProgressView("Processing...")
                        .padding()
                }

                if let receipt = receiptData {
                    NavigationLink(destination: EditReceiptView(receipt: receipt, onSave: { updatedReceipt in
                        self.receiptData = updatedReceipt
                        print("Receipt updated")
                        self.receiptData = nil
                    }, onCancel: {
                        print("Edit cancelled")
                    })) {
                        Text("Edit Scanned Receipt")
                            .foregroundColor(.blue)
                    }
                    .padding()
                }
            }
            .sheet(isPresented: $showImagePicker) {
                presentImagePicker()
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
        ReceiptProcessor.processImage(imageData) { receiptData in
            DispatchQueue.main.async {
                isProcessing = false
                if var receipt = receiptData {
                    receipt.scannedTime = Date()
                    print("Scanned time set to: \(receipt.scannedTime!)")
                    self.receiptData = receipt
                    print("Receipt processed successfully!")
                    if let userId = Auth.auth().currentUser?.uid {
                        FirestoreManager.shared.saveReceipt(receipt, forUser: userId) { result in
                            switch result {
                            case .success:
                                print("Receipt saved successfully")
                            case .failure(let error):
                                print("Failed to save receipt: \(error.localizedDescription)")
                            }
                        }
                    }
                } else {
                    print("Failed to process receipt.")
                }
            }
        }
    }
}
