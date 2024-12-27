import SwiftUI

struct ReceiptDetailView: View {
    let receipt: Receipt

    var body: some View {
        VStack {
            // Store details at the top
            VStack(alignment: .leading, spacing: 10) {
                Text("Store Name: \(receipt.storeName ?? "Unknown")")
                    .font(.headline)
                Text("Date: \(receipt.date ?? "Unknown")")
                Text("Total Amount: $\(receipt.totalAmount ?? 0, specifier: "%.2f")")
                Text("Tax Amount: $\(receipt.taxAmount ?? 0, specifier: "%.2f")")
                Text("Tip Amount: $\(receipt.tipAmount ?? 0, specifier: "%.2f")")
            }
            .padding()

            Divider() // Visual separator

            // Items purchased
            if let items = receipt.items, !items.isEmpty {
                LazyVStack {
                    // Table headers
                    HStack {
                        Text("Item")
                            .bold()
                        Spacer()
                        Text("Qty")
                            .bold()
                        Spacer()
                        Text("Price")
                            .bold()
                    }
                    .padding(.bottom, 8)

                    // Table rows
                    ForEach(items) { item in
                        HStack {
                            Text(item.name ?? "Unknown Item")
                            Spacer()
                            Text("\(item.quantity ?? 0, specifier: "%.0f")")
                            Spacer()
                            Text("$\(item.price ?? 0.0, specifier: "%.2f")")
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding()
            } else {
                // Fallback for no items
                Text("No items found.")
                    .foregroundColor(.gray)
                    .padding()
            }

            Spacer()
        }
        .navigationTitle(receipt.storeName ?? "Receipt Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
