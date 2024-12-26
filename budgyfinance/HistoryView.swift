import SwiftUI
import Charts

struct HistoryView: View {
    @FetchRequest(fetchRequest: Receipt.fetchAll()) var receipts: FetchedResults<Receipt>

    var body: some View {
        VStack {
            Text("Transaction History")
                .font(.title2)
                .padding()

            Chart {
                ForEach(receipts) { receipt in
                    LineMark(
                        x: .value("Date", formattedDate(receipt.date)),
                        y: .value("Amount", receipt.totalAmount)
                    )
                }
            }
            .frame(height: 300)
            .padding()

            List(receipts) { receipt in
                VStack(alignment: .leading) {
                    Text("Date: \(formattedDate(receipt.date))")
                    Text("Amount: $\(receipt.totalAmount, specifier: "%.2f")")
                    Text("Items: \(receipt.items)")
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
