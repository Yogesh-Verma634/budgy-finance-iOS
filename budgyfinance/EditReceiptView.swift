import SwiftUI

struct EditReceiptView: View {
    @State var receipt: Receipt
    var onSave: (Receipt) -> Void
    var onCancel: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Store Name Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Store Name")
                        .font(.headline)

                    TextField("Enter Store Name", text: Binding(
                        get: { receipt.storeName ?? "" },
                        set: { receipt.storeName = $0 }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                // Items Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Items")
                        .font(.headline)

                    ForEach(receipt.items?.indices ?? 0..<0, id: \.self) { index in
                        HStack(spacing: 12) {
                            TextField("Item Name", text: Binding(
                                get: { receipt.items?[index].name ?? "" },
                                set: { receipt.items?[index].name = $0 }
                            ))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: .infinity)

                            TextField("Price", value: Binding(
                                get: { receipt.items?[index].price ?? 0.0 },
                                set: { receipt.items?[index].price = $0 }
                            ), formatter: NumberFormatter.currency)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                            .frame(width: 80)

                            TextField("Qty", value: Binding(
                                get: { receipt.items?[index].quantity ?? 0.0 },
                                set: { receipt.items?[index].quantity = $0 }
                            ), formatter: NumberFormatter.decimal)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                            .frame(width: 60)
                        }
                    }

                    Button(action: {
                        if receipt.items == nil {
                            receipt.items = []
                        }
                        receipt.items?.append(ReceiptItem(name: nil, price: nil, quantity: nil))
                    }) {
                        Text("Add Item")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }

                // Total Section
                HStack {
                    Text("Total:")
                        .font(.headline)

                    Spacer()

                    Text("$\(receipt.totalAmount ?? 0.0, specifier: "%.2f")")
                        .font(.headline)
                }

                // Action Buttons
                HStack {
                    Button(action: { onSave(receipt) }) {
                        Text("Save Receipt")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }

                    Button(action: onCancel) {
                        Text("Cancel")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.black)
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Edit Receipt")
    }
}

extension NumberFormatter {
    static var currency: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter
    }

    static var decimal: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        return formatter
    }
}
