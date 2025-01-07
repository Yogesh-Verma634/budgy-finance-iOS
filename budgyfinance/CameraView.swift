import SwiftUI
import UIKit

struct CameraView: UIViewControllerRepresentable {
    enum SourceType {
        case camera
        case photoLibrary
    }

    @Binding var sourceType: SourceType
    @Binding var selectedImage: UIImage?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType == .camera ? .camera : .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                print("Image selected from CameraView")
                parent.selectedImage = image
            } else {
                print("Failed to select image from CameraView")
            }
            picker.dismiss(animated: true) {
                print("CameraView dismissed")
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            print("CameraView selection cancelled")
            picker.dismiss(animated: true)
        }
    }
}
