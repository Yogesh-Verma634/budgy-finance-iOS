import SwiftUI

struct ErrorDemo: View {
    @State private var showNetworkError = false
    @State private var showOCRError = false
    @State private var showParsingError = false
    @State private var isLoading = false
    @StateObject private var loadingManager = LoadingStateManager()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Error Handling Demo")
                .font(.largeTitle)
                .bold()
            
            VStack(spacing: 16) {
                LoadingButton(title: "Test Network Error", isLoading: isLoading) {
                    showNetworkError = true
                }
                
                LoadingButton(title: "Test OCR Error", isLoading: isLoading) {
                    showOCRError = true
                }
                
                LoadingButton(title: "Test Parsing Error", isLoading: isLoading) {
                    showParsingError = true
                }
                
                LoadingButton(title: "Test Loading State", isLoading: loadingManager.isLoading) {
                    testLoadingState()
                }
            }
        }
        .padding()
        .alert("Network Error", isPresented: $showNetworkError) {
            Button("Retry") {
                print("Retrying network operation...")
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(AppError.noInternetConnection.localizedDescription)
        }
        .alert("OCR Error", isPresented: $showOCRError) {
            Button("Retry") {
                print("Retrying OCR...")
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(AppError.ocrFailed.localizedDescription)
        }
        .alert("Parsing Error", isPresented: $showParsingError) {
            Button("OK") { }
        } message: {
            Text(AppError.receiptParsingFailed.localizedDescription)
        }
        .overlay(
            Group {
                if loadingManager.isLoading {
                    LoadingOverlay(
                        message: loadingManager.loadingMessage,
                        progress: loadingManager.progress > 0 ? loadingManager.progress : nil
                    )
                }
            }
        )
    }
    
    private func testLoadingState() {
        loadingManager.startLoading("demo", message: "Processing demo...")
        
        // Simulate progress
        var progress: Double = 0.0
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            progress += 0.1
            loadingManager.updateProgress(progress, message: "Processing... \(Int(progress * 100))%")
            
            if progress >= 1.0 {
                timer.invalidate()
                loadingManager.stopLoading("demo")
            }
        }
    }
}

#Preview {
    ErrorDemo()
}
