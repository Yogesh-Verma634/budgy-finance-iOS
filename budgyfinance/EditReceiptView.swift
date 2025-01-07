import SwiftUI

struct EditReceiptView: View {
    @State var receipt: Receipt
    var onSave: (Receipt) -> Void
    var onCancel: () -> Void
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Store Information")) {
                    TextField("Store Name", text: binding(for: \.storeName, defaultValue: ""))
                    TextField("Date", text: binding(for: \.date, defaultValue: ""))
                }

                Section(header: Text("Items")) {
                    if let items = receipt.items {
                        ForEach(items.indices, id: \.self) { index in
                            HStack {
                                TextField("Item Name", text: binding(for: \.items![index].name, defaultValue: ""))
                                TextField("Price", value: binding(for: \.items![index].price, defaultValue: 0.0), formatter: NumberFormatter.decimal)
                                TextField("Quantity", value: binding(for: \.items![index].quantity, defaultValue: 0.0), formatter: NumberFormatter.decimal)
                            }
                        }
                    }
                }
            }
            .navigationBarItems(
                leading: Button("Cancel") {
                    onCancel()
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    onSave(receipt)
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .navigationTitle("Edit Receipt")
        }
    }

    private func binding<T>(for keyPath: WritableKeyPath<Receipt, T?>, defaultValue: T) -> Binding<T> {
        Binding(
            get: { self.receipt[keyPath: keyPath] ?? defaultValue },
            set: { self.receipt[keyPath: keyPath] = $0 }
        )
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
