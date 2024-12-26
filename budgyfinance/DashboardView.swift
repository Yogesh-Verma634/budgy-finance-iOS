import SwiftUI
import Charts

struct DashboardView: View {
    @FetchRequest(fetchRequest: Receipt.fetchAll()) var receipts: FetchedResults<Receipt>
    @State private var monthlyGoal: Double = 2000.0

    var totalSpent: Double {
        receipts.reduce(0) { $0 + $1.totalAmount }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Spending Overview")
                    .font(.title2)
                    .padding()

                Chart {
                    ForEach(receipts) { receipt in
                        BarMark(
                            x: .value("Date", formattedDate(receipt.date)),
                            y: .value("Amount", receipt.totalAmount)
                        )
                    }
                }
                .frame(height: 300)
                .padding()

                Text("Category Breakdown")
                    .font(.headline)
                Chart {
                    ForEach(receipts) { receipt in
                        BarMark(
                            x: .value("Items", receipt.items),
                            y: .value("Amount", receipt.totalAmount)
                        )
                    }
                }
                .frame(height: 300)
                .padding()

                Text("Spending Insights")
                    .font(.headline)
                    .padding()

                Text("You're on track! Remaining budget: $\(monthlyGoal - totalSpent, specifier: "%.2f")")
                    .padding()
                    .foregroundColor(.blue)
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}
