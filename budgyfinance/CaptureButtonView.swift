import SwiftUI

struct CaptureView: View {
    @State private var showCameraView = false
    @State private var sourceType: CameraView.SourceType = .camera
    @State private var receiptData: Receipt?

    var body: some View {
        VStack {
            Button("Capture Receipt") {
                sourceType = .camera
                showCameraView = true
            }
            .padding()

            Button("Upload Receipt") {
                sourceType = .photoLibrary
                showCameraView = true
            }
            .padding()

            if let receipt = receiptData {
                Text("Receipt from \(receipt.storeName ?? "Unknown Store")")
                Text("Total: $\(receipt.totalAmount ?? 0, specifier: "%.2f")")
            }
        }
        .sheet(isPresented: $showCameraView) {
            CameraView(sourceType: $sourceType, receiptData: $receiptData)
        }
    }
}
