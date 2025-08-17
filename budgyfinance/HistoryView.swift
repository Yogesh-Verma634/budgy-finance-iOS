import SwiftUI
import FirebaseAuth

struct HistoryView: View {
    @EnvironmentObject var firestoreManager: FirestoreManager
    @State private var isRefreshing = false
    @State private var searchText = ""
    @State private var selectedSortOption: SortOption = .date
    @State private var selectedMonth: String = "All"
    
    enum SortOption: String, CaseIterable {
        case date = "Receipt Date" // Sort by when the transaction occurred
        case uploadDate = "Upload Date" // Sort by when the receipt was scanned/uploaded
        case amount = "Amount"
        case store = "Store"
    }
    
    var filteredAndSortedReceipts: [Receipt] {
        var receipts = firestoreManager.receiptsCache
        
        // Filter by search text
        if !searchText.isEmpty {
            receipts = receipts.filter { receipt in
                let storeName = receipt.storeName?.lowercased() ?? ""
                let items = receipt.items?.compactMap { $0.name?.lowercased() }.joined(separator: " ") ?? ""
                let searchLower = searchText.lowercased()
                
                return storeName.contains(searchLower) || 
                       items.contains(searchLower) ||
                       (receipt.category?.lowercased().contains(searchLower) ?? false)
            }
        }
        
        // Filter by month
        if selectedMonth != "All" {
            receipts = receipts.filter { receipt in
                // For month filtering, use the same logic as upload date sorting
                let receiptDate = receipt.scannedTime ?? receipt.parsedTransactionDateTime ?? receipt.parsedReceiptDate
                guard let date = receiptDate else { return false }
                let formatter = DateFormatter()
                formatter.dateFormat = "MMMM yyyy"
                let receiptMonth = formatter.string(from: date)
                return receiptMonth == selectedMonth
            }
        }
        
        // Sort receipts
        switch selectedSortOption {
        case .date:
            // Sort by actual receipt date and time (parsedTransactionDateTime for the transaction date/time)
            print("🔍 Sorting by receipt date (parsedTransactionDateTime)")
            receipts.forEach { receipt in
                let date = receipt.parsedTransactionDateTime ?? receipt.parsedReceiptDate ?? receipt.scannedTime ?? Date.distantPast
                print("   Receipt: \(receipt.storeName ?? "Unknown") - date: \(date)")
            }
            receipts.sort { (receipt1, receipt2) in
                let date1 = receipt1.parsedTransactionDateTime ?? receipt1.parsedReceiptDate ?? receipt1.scannedTime ?? Date.distantPast
                let date2 = receipt2.parsedTransactionDateTime ?? receipt2.parsedReceiptDate ?? receipt2.scannedTime ?? Date.distantPast
                print("   Comparing: \(receipt1.storeName ?? "Unknown") (\(date1)) vs \(receipt2.storeName ?? "Unknown") (\(date2))")
                return date1 > date2 // Most recent first
            }
            print("✅ Sorted receipts by receipt date")
        case .uploadDate:
            // Sort by when the receipt was uploaded/scanned (always use datetime for precision)
            // Primary: scannedTime (datetime when uploaded)
            // Fallback: Convert receipt date string to datetime with 00:00 time
            print("🔍 Sorting by upload date (datetime precision)")
            receipts.sort { (receipt1, receipt2) in
                // Get upload datetime for receipt1
                let dateTime1: Date = {
                    if let scannedTime = receipt1.scannedTime {
                        return scannedTime
                    }
                    if let dateString = receipt1.date {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        if let date = formatter.date(from: dateString) {
                            return date
                        }
                    }
                    return Date.distantPast
                }()
                
                // Get upload datetime for receipt2
                let dateTime2: Date = {
                    if let scannedTime = receipt2.scannedTime {
                        return scannedTime
                    }
                    if let dateString = receipt2.date {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        if let date = formatter.date(from: dateString) {
                            return date
                        }
                    }
                    return Date.distantPast
                }()
                
                print("   Comparing: \(receipt1.storeName ?? "Unknown") (\(dateTime1)) vs \(receipt2.storeName ?? "Unknown") (\(dateTime2))")
                return dateTime1 > dateTime2 // Most recent upload first
            }
            print("✅ Sorted receipts by upload date (datetime precision)")
        case .amount:
            receipts.sort { (receipt1, receipt2) in
                let amount1 = receipt1.totalAmount ?? 0
                let amount2 = receipt2.totalAmount ?? 0
                return amount1 > amount2
            }
        case .store:
            receipts.sort { (receipt1, receipt2) in
                let store1 = receipt1.storeName ?? ""
                let store2 = receipt2.storeName ?? ""
                return store1 < store2
            }
        }
        
        return receipts
    }
    
    var availableMonths: [String] {
        let months: [String] = firestoreManager.receiptsCache.compactMap { receipt in
            // For month availability, use the same logic as upload date sorting
            let receiptDate = receipt.scannedTime ?? receipt.parsedTransactionDateTime ?? receipt.parsedReceiptDate
            guard let date = receiptDate else { return nil }
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: date)
        }
        
        // Remove duplicates and sort by date (most recent first)
        let uniqueMonths = Array(Set(months)).sorted { month1, month2 in
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            let date1 = formatter.date(from: month1) ?? Date.distantPast
            let date2 = formatter.date(from: month2) ?? Date.distantPast
            return date1 > date2
        }
        
        return ["All"] + uniqueMonths
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and Filter Bar
                VStack(spacing: 12) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search receipts...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Sort and Filter Options
                    HStack {
                        // Sort Picker
                        Menu {
                            ForEach(SortOption.allCases, id: \.self) { option in
                                Button(option.rawValue) {
                                    selectedSortOption = option
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "arrow.up.arrow.down")
                                Text(selectedSortOption.rawValue)
                                Image(systemName: "chevron.down")
                            }
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        // Month Filter
                        Menu {
                            ForEach(availableMonths, id: \.self) { month in
                                Button(month) {
                                    selectedMonth = month
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "calendar")
                                Text(selectedMonth)
                                Image(systemName: "chevron.down")
                            }
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                
                // Receipts List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        if filteredAndSortedReceipts.isEmpty {
                            VStack(spacing: 20) {
                                Image(systemName: searchText.isEmpty ? "list.bullet.rectangle.portrait" : "magnifyingglass")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray.opacity(0.6))
                                Text(searchText.isEmpty ? "No History Yet" : "No Results Found")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                Text(searchText.isEmpty ? 
                                     "Your processed receipts will appear here. Pull down to refresh." :
                                     "Try adjusting your search terms or filters.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            .padding(.top, 50)
                        } else {
                            ForEach(filteredAndSortedReceipts) { receipt in
                                NavigationLink(destination: ReceiptDetailView(receipt: receipt)) {
                                    ReceiptRowView(receipt: receipt)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding()
                }
                .refreshable {
                    refreshReceipts()
                }
            }
            .navigationTitle("Transaction History")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            if firestoreManager.receiptsCache.isEmpty {
                refreshReceipts()
            }
        }
    }
    
    private func refreshReceipts() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not logged in, cannot refresh receipts.")
            return
        }
        isRefreshing = true
        firestoreManager.refreshCache(forUser: userId)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isRefreshing = false
        }
    }
    
    private func deleteReceipt(at offsets: IndexSet) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not logged in, cannot delete receipts.")
            return
        }
        guard let index = offsets.first else { return }
        let receipt = firestoreManager.receiptsCache[index]
        // Note: onDelete will not work directly on a ScrollView.
        // A custom implementation would be needed. For now, we rely on detail view for deletion.
        // Consider adding a swipe-to-delete gesture to the ReceiptRowView if needed.
        firestoreManager.deleteReceipt(receipt.id, forUser: userId) { error in
            if let error = error {
                print("Failed to delete receipt: \(error.localizedDescription)")
            }
        }
    }
}

struct ReceiptRowView: View {
    let receipt: Receipt

    var body: some View {
        HStack(spacing: 15) {
            // Category Icon
            Image(systemName: SpendingCategory(rawValue: receipt.category ?? "Other")?.icon ?? "circle.fill")
                .font(.title2)
                .foregroundColor(.white)
                .padding(12)
                .background(SpendingCategory(rawValue: receipt.category ?? "Other")?.color ?? .gray)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(receipt.storeName ?? "Unknown Store")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                HStack {
                    // Show receipt date (actual transaction date) if available, fallback to scanned time
                    if let receiptDate = formatReceiptDate(receipt) {
                        Text(receiptDate)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let category = receipt.category {
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(category)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(receipt.totalAmount ?? 0, specifier: "%.2f")")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                if let items = receipt.items, !items.isEmpty {
                    Text("\(items.count) item\(items.count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    

    // Helper method to format the receipt date for display
    private func formatReceiptDate(_ receipt: Receipt) -> String? {
        // First try to use the parsed transaction date and time
        if let parsedDateTime = receipt.parsedTransactionDateTime {
            let formatter = DateFormatter()
            // Check if the time is midnight (00:00) - if so, show date only
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: parsedDateTime)
            let minute = calendar.component(.minute, from: parsedDateTime)
            
            if hour == 0 && minute == 0 {
                // Time is midnight, show date only
                formatter.dateStyle = .medium
                formatter.timeStyle = .none
            } else {
                // Time is available, show both date and time
                formatter.dateStyle = .medium
                formatter.timeStyle = .short
            }
            return formatter.string(from: parsedDateTime)
        }
        
        // Fallback to parsed receipt date (date only)
        if let parsedDate = receipt.parsedReceiptDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: parsedDate)
        }
        
        // Fallback to scanned time if receipt date is not available
        if let scannedTime = receipt.scannedTime {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: scannedTime)
        }
        
        // If neither is available, try to show the original date string
        if let dateString = receipt.date {
            return dateString
        }
        
        return nil
    }
}
