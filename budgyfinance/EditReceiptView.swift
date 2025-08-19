import SwiftUI

struct EditReceiptView: View {
    @State var receipt: Receipt
    var onSave: (Receipt) -> Void
    var onCancel: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteAlert = false

    var body: some View {
        NavigationView {
            ZStack {
                // Modern background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 24) {
                        // Receipt Summary Card
                        receiptSummaryCard
                        
                        // Store Information Section
                        storeInformationSection
                        
                        // Items Section
                        itemsSection
                        
                        // Bottom padding for safe area
                        Color.clear.frame(height: 100)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Edit Receipt")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    modernCancelButton
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    modernSaveButton
                }
            }
        }
        .alert("Delete Receipt", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                onCancel()
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this receipt? This action cannot be undone.")
        }
    }
    
    private var receiptSummaryCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Amount")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(totalAmount, format: .currency(code: "USD"))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Items")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(receipt.items?.count ?? 0)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
            }
            
            // Category indicator
            if let category = receipt.category {
                HStack {
                    if let spendingCategory = SpendingCategory(rawValue: category) {
                        Label(category, systemImage: spendingCategory.icon)
                            .font(.caption)
                            .foregroundColor(Color(spendingCategory.color))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(spendingCategory.color).opacity(0.1))
                            .clipShape(Capsule())
                    }
                    
                    Spacer()
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var storeInformationSection: some View {
        ModernSection(title: "Store Information", icon: "storefront") {
            VStack(spacing: 16) {
                ModernTextField(
                    title: "Store Name",
                    text: binding(for: \.storeName, defaultValue: ""),
                    placeholder: "Enter store name",
                    icon: "storefront.fill"
                )
                
                ModernTextField(
                    title: "Date",
                    text: binding(for: \.date, defaultValue: ""),
                    placeholder: "YYYY-MM-DD",
                    icon: "calendar"
                )
                
                ModernCategoryPicker(
                    title: "Category",
                    selectedCategory: binding(for: \.category, defaultValue: "Other")
                )
            }
        }
    }
    
    private var itemsSection: some View {
        ModernSection(title: "Items", icon: "list.bullet.rectangle") {
            VStack(spacing: 16) {
                if let items = receipt.items, !items.isEmpty {
                    ForEach(items.indices, id: \.self) { index in
                        ModernItemRow(
                            item: Binding(
                                get: { receipt.items![index] },
                                set: { receipt.items![index] = $0 }
                            ),
                            onDelete: {
                                receipt.items?.remove(at: index)
                            }
                        )
                    }
                } else {
                    EmptyItemsView()
                }
                
                // Add Item Button
                addItemButton
            }
        }
    }
    
    private var addItemButton: some View {
        Button(action: addNewItem) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                    .foregroundColor(.blue)
                
                Text("Add Item")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                
                Spacer()
            }
            .padding(16)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(ModernButtonPressStyle())
    }
    
    private var modernCancelButton: some View {
        Button(action: {
            onCancel()
            dismiss()
        }) {
            Text("Cancel")
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.red)
        }
    }
    
    private var modernSaveButton: some View {
        Button(action: {
            onSave(receipt)
            dismiss()
        }) {
            Text("Save")
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.blue)
                .clipShape(Capsule())
        }
        .buttonStyle(ModernButtonPressStyle())
    }
    
    private var totalAmount: Double {
        receipt.items?.reduce(0) { total, item in
            let price = item.price ?? 0.0
            let quantity = item.quantity ?? 1.0
            return total + (price * quantity)
        } ?? 0
    }
    
    private func addNewItem() {
        let newItem = ReceiptItem(
            id: UUID().uuidString,
            name: "",
            price: 0.0,
            quantity: 1.0,
            category: "Other"
        )
        
        if receipt.items == nil {
            receipt.items = []
        }
        receipt.items?.append(newItem)
    }

    private func binding<T>(for keyPath: WritableKeyPath<Receipt, T?>, defaultValue: T) -> Binding<T> {
        Binding(
            get: { self.receipt[keyPath: keyPath] ?? defaultValue },
            set: { self.receipt[keyPath: keyPath] = $0 }
        )
    }
}

// MARK: - Modern Components

struct ModernSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.blue)
                
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            content
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct ModernTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            
            TextField(placeholder, text: $text)
                .font(.body)
                .padding(12)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.separator), lineWidth: 0.5)
                )
        }
    }
}

struct ModernCategoryPicker: View {
    let title: String
    @Binding var selectedCategory: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "tag.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(SpendingCategory.allCases, id: \.self) { category in
                        ModernCategoryChip(
                            category: category,
                            isSelected: selectedCategory == category.rawValue
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedCategory = category.rawValue
                            }
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
}

struct ModernCategoryChip: View {
    let category: SpendingCategory
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text(category.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Group {
                    if isSelected {
                        Color(category.color)
                    } else {
                        Color(.secondarySystemGroupedBackground)
                    }
                }
            )
            .clipShape(Capsule())
            .foregroundColor(isSelected ? .white : .primary)
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : Color(.separator), lineWidth: 0.5)
            )
        }
        .buttonStyle(ModernButtonPressStyle())
    }
}

struct ModernItemRow: View {
    @Binding var item: ReceiptItem
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Item name - full width for maximum visibility
            HStack(spacing: 12) {
                ModernItemTextField(
                    placeholder: "Item name",
                    text: Binding(
                        get: { item.name ?? "" },
                        set: { item.name = $0 }
                    ),
                    icon: "bag.fill"
                )
                
                // Delete button on the right
                Button(action: onDelete) {
                    Image(systemName: "trash.fill")
                        .font(.body)
                        .foregroundColor(.red)
                        .padding(10)
                        .background(Color.red.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(ModernButtonPressStyle())
            }
            
            // Price and Quantity in a compact row
            HStack(spacing: 16) {
                ModernItemTextField(
                    placeholder: "$0.00",
                    value: Binding(
                        get: { item.price ?? 0.0 },
                        set: { item.price = $0 }
                    ),
                    formatter: .currency,
                    icon: "dollarsign.circle.fill"
                )
                
                ModernItemTextField(
                    placeholder: "Qty: 1",
                    value: Binding(
                        get: { item.quantity ?? 1.0 },
                        set: { item.quantity = $0 }
                    ),
                    formatter: .decimal,
                    icon: "number.circle.fill"
                )
            }
            
            // Item category picker
            ModernCategoryPicker(
                title: "Category",
                selectedCategory: Binding(
                    get: { item.category ?? "Other" },
                    set: { item.category = $0 }
                )
            )
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
    }
}

struct ModernItemTextField: View {
    let placeholder: String
    let textBinding: Binding<String>?
    let valueBinding: Binding<Double>?
    let formatter: NumberFormatter?
    let icon: String
    
    // String initializer
    init(placeholder: String, text: Binding<String>, icon: String) {
        self.placeholder = placeholder
        self.textBinding = text
        self.valueBinding = nil
        self.formatter = nil
        self.icon = icon
    }
    
    // Double with formatter initializer
    init(placeholder: String, value: Binding<Double>, formatter: NumberFormatter, icon: String) {
        self.placeholder = placeholder
        self.textBinding = nil
        self.valueBinding = value
        self.formatter = formatter
        self.icon = icon
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundColor(.secondary)
                .frame(width: 12)
            
            Group {
                if let textBinding = textBinding {
                    TextField(placeholder, text: textBinding)
                        .foregroundColor(.primary)
                } else if let valueBinding = valueBinding, let formatter = formatter {
                    TextField(placeholder, value: valueBinding, formatter: formatter)
                        .foregroundColor(.primary)
                }
            }
            .font(.subheadline)
            .fontWeight(.medium)
        }
        .padding(12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
    }
}

struct EmptyItemsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "list.bullet.rectangle")
                .font(.title)
                .foregroundColor(.secondary)
            
            Text("No items yet")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Add items from your receipt")
                .font(.caption)
                .foregroundColor(.secondary.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(Color(.tertiarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct ModernButtonPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
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
