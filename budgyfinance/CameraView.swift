import SwiftUI
import Vision
import UIKit

struct CameraView: UIViewControllerRepresentable {
    enum SourceType {
        case camera, photoLibrary
    }

    @Binding var sourceType: SourceType

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

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                processImage(image)
            }
            picker.dismiss(animated: true)
        }

        private func processImage(_ image: UIImage) {
            guard let cgImage = image.cgImage else { return }
            let request = VNRecognizeTextRequest { (request, error) in
                guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
                
                let context = CoreDataManager.shared.container.viewContext
                let receipt = Receipt(context: context)
                receipt.date = Date()
                receipt.totalAmount = 0.0
                receipt.items = ""
                
                for observation in observations {
                    if let topCandidate = observation.topCandidates(1).first {
                        print("Recognized text: \(topCandidate.string)")
                    }
                }

                do {
                    try context.save()
                } catch {
                    print("Failed to save receipt: \(error)")
                }
            }
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? handler.perform([request])
        }
    }
}
