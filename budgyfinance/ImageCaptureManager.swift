import SwiftUI
import UIKit

class ImageCaptureManager: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var showImageConfirmation: Bool = false
    
    func setImage(_ image: UIImage) {
        print("📱 ImageCaptureManager: Setting image with size: \(image.size)")
        DispatchQueue.main.async {
            self.selectedImage = image
            print("📱 ImageCaptureManager: Image set, now showing confirmation")
            self.showImageConfirmation = true
        }
    }
    
    func clearImage() {
        print("📱 ImageCaptureManager: Clearing image")
        selectedImage = nil
        showImageConfirmation = false
    }
    
    func hideConfirmation() {
        print("📱 ImageCaptureManager: Hiding confirmation")
        showImageConfirmation = false
    }
}
