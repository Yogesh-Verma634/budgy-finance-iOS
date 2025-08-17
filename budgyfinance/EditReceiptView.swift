import SwiftUI

struct EditReceiptView: View {
    @State var receipt: Receipt
    var onSave: (Receipt) -> Void
    var onCancel: () -> Void
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Section(header: Text("Store Information").font(.title2).fontWeight(.bold)) {
                        VStack(spacing: 12) {
                            StyledTextField(placeholder: "Store Name", text: binding(for: \.storeName, defaultValue: ""))
                            StyledTextField(placeholder: "Date", text: binding(for: \.date, defaultValue: ""))
                        }
                    }

                    Section(header: Text("Category").font(.title2).fontWeight(.bold)) {
                        CategoryPicker(selectedCategory: binding(for: \.category, defaultValue: "Other"))
                    }

                    Section(header: Text("Items").font(.title2).fontWeight(.bold)) {
                        VStack(spacing: 12) {
                            if let items = receipt.items {
                                ForEach(items.indices, id: \.self) { index in
                                    VStack(spacing: 8) {
                                        HStack(spacing: 8) {
                                            StyledTextField(placeholder: "Item", text: binding(for: \.items![index].name, defaultValue: ""))
                                            StyledTextField(placeholder: "Price", value: binding(for: \.items![index].price, defaultValue: 0.0), formatter: .decimal)
                                                .frame(maxWidth: 80)
                                            StyledTextField(placeholder: "Qty", value: binding(for: \.items![index].quantity, defaultValue: 0.0), formatter: .decimal)
                                                .frame(maxWidth: 60)
                                        }
                                        
                                        // Category picker for individual items
                                        CategoryPicker(selectedCategory: binding(for: \.items![index].category, defaultValue: "Other"))
                                            .padding(.leading)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGray6).ignoresSafeArea())
            .navigationBarItems(
                leading: Button("Cancel") {
                    onCancel()
                    presentationMode.wrappedValue.dismiss()
                }.foregroundColor(.red),
                trailing: Button("Save") {
                    onSave(receipt)
                    presentationMode.wrappedValue.dismiss()
                }
                .fontWeight(.bold)
                .buttonStyle(.borderedProminent)
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

struct CategoryPicker: View {
    @Binding var selectedCategory: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Category")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(SpendingCategory.allCases, id: \.self) { category in
                        CategoryChip(
                            category: category,
                            isSelected: selectedCategory == category.rawValue
                        ) {
                            selectedCategory = category.rawValue
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

struct CategoryChip: View {
    let category: SpendingCategory
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.caption)
                Text(category.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color(category.color) : Color(.systemGray5))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct StyledTextField: View {
    let placeholder: String
    let textBinding: Binding<String>?
    let valueBinding: Binding<Double>?
    let formatter: NumberFormatter?
    
    // String initializer
    init(placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self.textBinding = text
        self.valueBinding = nil
        self.formatter = nil
    }
    
    // Double with formatter initializer
    init(placeholder: String, value: Binding<Double>, formatter: NumberFormatter) {
        self.placeholder = placeholder
        self.textBinding = nil
        self.valueBinding = value
        self.formatter = formatter
    }

    var body: some View {
        Group {
            if let textBinding = textBinding {
                TextField(placeholder, text: textBinding)
                    .textFieldStyle()
            } else if let valueBinding = valueBinding, let formatter = formatter {
                TextField(placeholder, value: valueBinding, formatter: formatter)
                    .textFieldStyle()
            }
        }
    }
}

extension View {
    func textFieldStyle() -> some View {
        self
            .padding(12)
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
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
