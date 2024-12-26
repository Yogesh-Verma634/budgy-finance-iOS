import SwiftUI

struct CaptureView: View {
    @State private var showCameraView = false
    @State private var showPhotoLibrary = false
    @State private var sourceType: CameraView.SourceType = .camera

    var body: some View {
        VStack(spacing: 40) {
            Text("Scan Receipt")
                .font(.title2)
                .padding(.top)

            Button(action: {
                sourceType = .camera
                showCameraView = true
            }) {
                VStack {
                    Image(systemName: "camera")
                        .font(.largeTitle)
                        .padding()
                    Text("Capture Receipt")
                        .font(.headline)
                }
                .frame(width: 200, height: 100)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
            }

            Button(action: {
                sourceType = .photoLibrary
                showPhotoLibrary = true
            }) {
                VStack {
                    Image(systemName: "arrow.up.circle")
                        .font(.largeTitle)
                        .padding()
                    Text("Upload Receipt")
                        .font(.headline)
                }
                .frame(width: 200, height: 100)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
            }

            Spacer()
        }
        .sheet(isPresented: $showCameraView) {
            CameraView(sourceType: $sourceType)
        }
        .sheet(isPresented: $showPhotoLibrary) {
            CameraView(sourceType: $sourceType)
        }
        .padding()
    }
}
