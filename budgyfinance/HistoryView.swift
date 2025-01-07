import SwiftUI
import Firebase

struct HistoryView: View {
    @State private var receipts: [Receipt] = []
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading receipts...")
                } else if receipts.isEmpty {
                    Text("No receipts found.")
                        .font(.headline)
                        .foregroundColor(.gray)
                } else {
                    List(receipts) { receipt in
                        NavigationLink(destination: ReceiptDetailView(receipt: receipt)) {
                            VStack(alignment: .leading) {
                                Text(receipt.storeName ?? "Unknown Store")
                                    .font(.headline)
                                Text("Date: \(receipt.date ?? "Unknown Date")")
                                Text("Total: $\(receipt.totalAmount ?? 0, specifier: "%.2f")")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Transaction History")
            .onAppear {
                clearLocalState()
                clearFirestoreCacheAndFetch()
            }
        }
    }

    private func clearFirestoreCacheAndFetch() {
        clearFirestoreCache { success in
            if success {
                fetchReceipts()
            } else {
                print("Failed to clear Firestore cache")
                isLoading = false
            }
        }
    }

    private func clearFirestoreCache(completion: @escaping (Bool) -> Void) {
        Firestore.firestore().clearPersistence { error in
            if let error = error {
                print("Error clearing Firestore cache: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Firestore cache cleared")
                completion(true)
            }
        }
    }

    private func fetchReceipts() {
        print("Fetching receipts from Firestore")
        isLoading = true
        FirestoreManager.shared.fetchReceipts { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let fetchedReceipts):
                    print("Fetched receipts: \(fetchedReceipts.count)")
                    receipts = fetchedReceipts
                case .failure(let error):
                    print("Failed to fetch receipts: \(error.localizedDescription)")
                    receipts.removeAll() // Ensure state reflects no data if fetch fails
                }
            }
        }
    }

    private func clearLocalState() {
        receipts.removeAll()
        isLoading = false
    }
}
