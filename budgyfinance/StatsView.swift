import SwiftUI

struct StatsView: View {
    @State private var receipts: [Receipt] = []
    @State private var totalSpent: Double = 0.0
    @State private var isLoading = true

    var body: some View {
        VStack(alignment: .leading) {
            if isLoading {
                ProgressView("Loading analytics...")
            } else {
                Text("Spending Analytics")
                    .font(.title2)
                    .padding()

                HStack {
                    VStack(alignment: .leading) {
                        Text("This Month")
                            .font(.headline)
                        Text("$\(totalSpent, specifier: "%.2f")")
                            .font(.largeTitle)
                            .foregroundColor(.primary)
                    }
                }
                .padding()

                Spacer()
            }
        }
        .padding()
        .onAppear {
            fetchReceipts()
        }
    }

    private func fetchReceipts() {
        FirestoreManager.shared.fetchReceipts { result in
            switch result {
            case .success(let fetchedReceipts):
                DispatchQueue.main.async {
                    receipts = fetchedReceipts
                    totalSpent = fetchedReceipts.reduce(0) { $0 + ($1.totalAmount ?? 0) }
                    isLoading = false
                }
            case .failure(let error):
                print("Failed to fetch receipts: \(error.localizedDescription)")
                isLoading = false
            }
        }
    }
}
