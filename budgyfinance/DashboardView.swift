import SwiftUI
import Charts

struct EditableReceiptView: View {
    @Binding var receiptData: Receipt

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Edit Receipt")
                .font(.title2)
                .padding()

            ForEach(receiptData.items.indices, id: \.self) { index in
                HStack {
                    TextField("Item Name", text: $receiptData.items[index].name)
                    TextField("Price", value: $receiptData.items[index].price, format: .number)
                        .keyboardType(.decimalPad)
                }
            }

            HStack {
                Text("Total:")
                    .font(.headline)
                Spacer()
                Text("$\(receiptData.totalAmount, specifier: "%.2f")")
                    .font(.headline)
            }

            Button(action: {
                // Save updated receipt data
                print("Receipt saved!")
            }) {
                Text("Save Receipt")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Button(action: {
                // Cancel edits
                print("Editing canceled.")
            }) {
                Text("Cancel")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.black)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}
