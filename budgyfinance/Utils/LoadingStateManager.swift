import Foundation
import SwiftUI

// MARK: - Loading State Manager
class LoadingStateManager: ObservableObject {
    @Published var isLoading = false
    @Published var loadingMessage = "Loading..."
    @Published var progress: Double = 0.0
    
    private var loadingTasks: Set<String> = []
    
    func startLoading(_ taskId: String, message: String = "Loading...") {
        DispatchQueue.main.async {
            self.loadingTasks.insert(taskId)
            self.loadingMessage = message
            self.isLoading = true
            self.progress = 0.0
        }
    }
    
    func updateProgress(_ progress: Double, message: String? = nil) {
        DispatchQueue.main.async {
            self.progress = progress
            if let message = message {
                self.loadingMessage = message
            }
        }
    }
    
    func stopLoading(_ taskId: String) {
        DispatchQueue.main.async {
            self.loadingTasks.remove(taskId)
            if self.loadingTasks.isEmpty {
                self.isLoading = false
                self.progress = 0.0
                self.loadingMessage = "Loading..."
            }
        }
    }
    
    func stopAllLoading() {
        DispatchQueue.main.async {
            self.loadingTasks.removeAll()
            self.isLoading = false
            self.progress = 0.0
            self.loadingMessage = "Loading..."
        }
    }
}

// MARK: - Loading View Components
struct LoadingOverlay: View {
    let message: String
    let progress: Double?
    
    init(message: String = "Loading...", progress: Double? = nil) {
        self.message = message
        self.progress = progress
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                if let progress = progress {
                    ProgressView(value: progress)
                        .frame(width: 200)
                        .progressViewStyle(LinearProgressViewStyle())
                } else {
                    ProgressView()
                        .scaleEffect(1.5)
                }
                
                Text(message)
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .padding(30)
            .background(Color.black.opacity(0.8))
            .cornerRadius(15)
        }
    }
}

struct LoadingButton: View {
    let title: String
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
                Text(isLoading ? "Processing..." : title)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isLoading ? Color.gray : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .disabled(isLoading)
    }
}

// MARK: - Error Alert View
struct ErrorAlert: View {
    @Binding var isPresented: Bool
    let error: AppError
    let retryAction: (() -> Void)?
    
    var body: some View {
        EmptyView()
            .alert(isPresented: $isPresented) {
                if let retryAction = retryAction, error.isRetryable {
                    return Alert(
                        title: Text("Error"),
                        message: Text(error.localizedDescription),
                        primaryButton: .default(Text("Retry"), action: retryAction),
                        secondaryButton: .cancel()
                    )
                } else {
                    return Alert(
                        title: Text("Error"),
                        message: Text(error.localizedDescription),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
    }
}
