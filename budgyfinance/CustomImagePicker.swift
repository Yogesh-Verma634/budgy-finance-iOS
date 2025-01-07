import SwiftUI
import PhotosUI

struct CustomImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: CustomImagePicker

        init(_ parent: CustomImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else {
                print("No image selected or unable to load image")
                parent.presentationMode.wrappedValue.dismiss()
                return
            }

            provider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
                DispatchQueue.main.async {
                    if let uiImage = image as? UIImage {
                        print("Image loaded successfully")
                        self?.parent.selectedImage = uiImage
                        self?.parent.presentationMode.wrappedValue.dismiss()
                    } else {
                        print("Failed to load image")
                        self?.parent.presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
} 