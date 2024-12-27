import SwiftUI
import Charts

struct HistoryView: View {
    @State private var receipts: [Receipt] = [] // Single declaration
    @State private var isLoading = true // Single declaration

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading transaction history...")
            } else {
                Text("Transaction History")
                    .font(.title2)
                    .padding()

                Chart {
                    ForEach(receipts, id: \.id) { receipt in
                        LineMark(
                            x: .value("Date", formattedDate(receipt.date)),
                            y: .value("Amount", receipt.totalAmount)
                        )
                    }
                }
                .frame(height: 300)
                .padding()

                List(receipts, id: \.id) { receipt in
                    VStack(alignment: .leading) {
                        Text("Date: \(formattedDate(receipt.date))")
                        Text("Amount: $\(receipt.totalAmount, specifier: "%.2f")")
                        Text("Items: \(receipt.items.map { $0.name }.joined(separator: ", "))")
                    }
                }
            }
        }
        .onAppear {
            fetchReceipts()
        }
    }

    private func fetchReceipts() {
        FirestoreManager.shared.fetchReceipts(forUser: "exampleUserId") { result in
            switch result {
            case .success(let fetchedReceipts):
                DispatchQueue.main.async {
                    receipts = fetchedReceipts
                    isLoading = false
                }
            case .failure(let error):
                print("Error fetching receipts: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    isLoading = false
                }
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}
