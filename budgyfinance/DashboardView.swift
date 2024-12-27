import SwiftUI
import Charts

struct DashboardView: View {
    @State private var receipts: [Receipt] = [] // Replace with data from Firestore
    @State private var monthlyGoal: Double = 2000.0

    var totalSpent: Double {
        receipts.reduce(0) { $0 + ($1.totalAmount ?? 0.0) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Spending Overview")
                    .font(.title2)
                    .padding()

                if receipts.isEmpty {
                    Text("No data available to display.")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    Chart {
                        ForEach(receipts, id: \.id) { receipt in
                            BarMark(
                                x: .value("Date", receipt.date ?? "1/1/1900"),
                                y: .value("Amount", receipt.totalAmount ?? 0.0)
                            )
                        }
                    }
                    .frame(height: 300)
                    .padding()

                    Text("Category Breakdown")
                        .font(.headline)
                    Chart {
                        ForEach(receipts, id: \.id) { receipt in
                            BarMark(
                                x: .value("Items", receipt.items?.count ?? 0),
                                y: .value("Amount", receipt.totalAmount ?? 0.0)
                            )
                        }
                    }
                    .frame(height: 300)
                    .padding()
                }

                Text("Spending Insights")
                    .font(.headline)
                    .padding()

                Text("You're on track! Remaining budget: $\(monthlyGoal - totalSpent, specifier: "%.2f")")
                    .padding()
                    .foregroundColor(.blue)
            }
        }
        .onAppear {
            loadReceipts()
        }
    }

    private func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "Unknown Date" }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }

    private func loadReceipts() {
        FirestoreManager.shared.fetchReceipts(forUser: "exampleUserId") { result in
            switch result {
            case .success(let fetchedReceipts):
                DispatchQueue.main.async {
                    self.receipts = fetchedReceipts
                }
            case .failure(let error):
                print("Error fetching receipts: \(error.localizedDescription)")
            }
        }
    }
}
