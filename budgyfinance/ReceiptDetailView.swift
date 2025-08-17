import SwiftUI

struct ReceiptDetailView: View {
    let receipt: Receipt

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header with store info
                VStack {
                    Image(systemName: "scroll.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                        .padding(.bottom, 5)
                    
                    Text(receipt.storeName ?? "Unknown Store")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(formatReceiptDate(receipt))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                
                // Financial summary
                HStack(spacing: 12) {
                    FinancialDetailCell(title: "Total", amount: receipt.totalAmount ?? 0, color: .blue)
                    FinancialDetailCell(title: "Tax", amount: receipt.taxAmount ?? 0, color: .green)
                    FinancialDetailCell(title: "Tip", amount: receipt.tipAmount ?? 0, color: .purple)
                }

                // Items list
                VStack(alignment: .leading) {
                    Text("Purchased Items")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.bottom, 5)
                    
                    if let items = receipt.items, !items.isEmpty {
                        ForEach(items) { item in
                            ItemRow(item: item)
                        }
                    } else {
                        Text("No items found.")
                            .foregroundColor(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Receipt Details")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGray6).ignoresSafeArea())
    }
    
    // Helper method to format the receipt date for display
    private func formatReceiptDate(_ receipt: Receipt) -> String {
        // First try to use the parsed transaction date and time
        if let parsedDateTime = receipt.parsedTransactionDateTime {
            let formatter = DateFormatter()
            // Check if the time is midnight (00:00) - if so, show date only
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: parsedDateTime)
            let minute = calendar.component(.minute, from: parsedDateTime)
            
            if hour == 0 && minute == 0 {
                // Time is midnight, show date only
                formatter.dateStyle = .full
                formatter.timeStyle = .none
            } else {
                // Time is available, show both date and time
                formatter.dateStyle = .full
                formatter.timeStyle = .short
            }
            return formatter.string(from: parsedDateTime)
        }
        
        // Fallback to parsed receipt date (date only)
        if let parsedDate = receipt.parsedReceiptDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .full
            formatter.timeStyle = .none
            return formatter.string(from: parsedDate)
        }
        
        // Fallback to scanned time if receipt date is not available
        if let scannedTime = receipt.scannedTime {
            let formatter = DateFormatter()
            formatter.dateStyle = .full
            formatter.timeStyle = .none
            return formatter.string(from: scannedTime)
        }
        
        // If neither is available, try to show the original date string
        if let dateString = receipt.date {
            return dateString
        }
        
        return "Unknown Date"
    }
}

struct FinancialDetailCell: View {
    let title: String
    let amount: Double
    let color: Color
    
    var body: some View {
        VStack {
            Text(title)
                .font(.footnote)
                .foregroundColor(.secondary)
            Text(String(format: "$%.2f", amount))
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct ItemRow: View {
    let item: ReceiptItem
    
    var body: some View {
        HStack {
            Text(item.name ?? "Unknown Item")
                .font(.headline)
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(String(format: "$%.2f", item.price ?? 0.0))
                    .fontWeight(.bold)
                if let quantity = item.quantity, quantity > 0 {
                    Text("Qty: \(String(format: "%.1f", quantity))")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
