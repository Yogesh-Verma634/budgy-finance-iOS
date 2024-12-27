import SwiftUI
import UIKit

struct CameraView: UIViewControllerRepresentable {
    enum SourceType {
        case camera, photoLibrary
    }

    @Binding var sourceType: SourceType
    @Binding var receiptData: Receipt?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType == .camera ? .camera : .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage, let imageData = image.jpegData(compressionQuality: 0.8) {
                ReceiptProcessor.processImage(imageData) { receiptData in
                    DispatchQueue.main.async {
                        if let receipt = receiptData {
                            print("Receipt processed successfully!")
                        } else {
                            print("Failed to process receipt.")
                        }
                    }
                }
            } else {
                print("Failed to convert UIImage to Data")
            }
            picker.dismiss(animated: true)
        }
    }
}
