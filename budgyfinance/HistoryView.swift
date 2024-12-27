import SwiftUI
import FirebaseFirestore

struct HistoryView: View {
    @State private var receipts: [Receipt] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading...")
                } else if let errorMessage = errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                } else if receipts.isEmpty {
                    Text("No receipts found.")
                        .font(.headline)
                        .padding()
                } else {
                    List(receipts) { receipt in
                        NavigationLink(destination: ReceiptDetailView(receipt: receipt)) {
                            VStack(alignment: .leading) {
                                Text(receipt.storeName ?? "Unknown Store")
                                    .font(.headline)
                                Text("Date: \(receipt.date ?? "Unknown Date")")
                                    .font(.subheadline)
                                Text("Total: $\(receipt.totalAmount ?? 0.0, specifier: "%.2f")")
                                    .font(.subheadline)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Transaction History")
            .onAppear {
                fetchReceipts()
            }
        }
    }

    private func fetchReceipts() {
        isLoading = true
        FirestoreManager.shared.fetchReceipts(forUser: "exampleUserId") { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let fetchedReceipts):
                    receipts = fetchedReceipts
                case .failure(let error):
                    errorMessage = "Failed to fetch receipts: \(error.localizedDescription)"
                }
            }
        }
    }
}
