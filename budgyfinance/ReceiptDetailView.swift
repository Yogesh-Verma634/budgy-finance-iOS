import SwiftUI

struct ReceiptDetailView: View {
    let receipt: Receipt

    var body: some View {
        VStack(alignment: .leading) {
            Text("Receipt Details")
                .font(.largeTitle)
                .padding()

            VStack(alignment: .leading, spacing: 10) {
                Text("Store Name: \(receipt.storeName ?? "Unknown")")
                    .font(.headline)
                Text("Date: \(receipt.date ?? "Unknown")")
                Text("Total Amount: $\(receipt.totalAmount ?? 0, specifier: "%.2f")")
                Text("Tax Amount: $\(receipt.taxAmount ?? 0, specifier: "%.2f")")
                Text("Tip Amount: $\(receipt.tipAmount ?? 0, specifier: "%.2f")")
            }
            .padding()

            Text("Items:")
                .font(.headline)
                .padding(.top)

            if let items = receipt.items {
                List(items) { item in
                    HStack {
                        Text(item.name ?? "Unknown Item")
                        Spacer()
                        Text("Qty: \(item.quantity ?? 0)")
                        Text("$\(item.price ?? 0, specifier: "%.2f")")
                    }
                }
                .listStyle(InsetGroupedListStyle())
            } else {
                Text("No items found.")
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Receipt Details")
    }
}
