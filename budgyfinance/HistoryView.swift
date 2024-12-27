import SwiftUI

struct HistoryView: View {
    @State private var receipts: [Receipt] = []
    @State private var isLoading = true

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading...")
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
                                HStack {
                                    Text("Date: \(receipt.date ?? "Unknown Date")")
                                    Spacer()
                                    Text("Total: $\(receipt.totalAmount ?? 0.0, specifier: "%.2f")")
                                }
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
        FirestoreManager.shared.fetchReceipts { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let fetchedReceipts):
                    receipts = fetchedReceipts
                case .failure(let error):
                    print("Failed to fetch receipts: \(error.localizedDescription)")
                }
            }
        }
    }
}
