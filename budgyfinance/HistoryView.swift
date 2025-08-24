import SwiftUI
import FirebaseAuth

struct HistoryView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
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
            ZStack {
                // Animated gradient background
                GlassmorphismBackground()
                
                VStack(spacing: 0) {
                    // Header
                    GlassmorphicHistoryHeader()
                    
                    // Search and Filter Bar
                    GlassmorphicSearchAndFilterBar(
                        searchText: $searchText,
                        selectedSortOption: $selectedSortOption,
                        selectedMonth: $selectedMonth,
                        availableMonths: availableMonths
                    )
                    
                    // Receipts List
                    if filteredAndSortedReceipts.isEmpty {
                        GlassmorphicEmptyHistoryView(searchText: searchText)
                    } else {
                        GlassmorphicReceiptsList(receipts: filteredAndSortedReceipts)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .refreshable {
                refreshReceipts()
            }
            .onAppear {
                // Fetch receipts when view appears if not already loaded
                if firestoreManager.receiptsCache.isEmpty {
                    refreshReceipts()
                }
            }
        }
    }
    
    private func refreshReceipts() {
        isRefreshing = true
        
        guard let userId = authViewModel.currentUser?.uid else {
            isRefreshing = false
            return
        }
        
        // Use completion handler since fetchReceipts is not async
        firestoreManager.fetchReceipts(forUser: userId) { result in
            DispatchQueue.main.async {
                self.isRefreshing = false
                // The receipts will be automatically updated in the cache
                // and the view will refresh due to @Published property
            }
        }
    }
}

// MARK: - Glassmorphic History Header
struct GlassmorphicHistoryHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Receipt History")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("View and manage your receipts")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                // History icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.orange.opacity(0.3), Color.red.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                    
                    Image(systemName: "clock.arrow.circlepath")
                        .foregroundColor(.white)
                        .font(.title2)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
}

// MARK: - Glassmorphic Search and Filter Bar
struct GlassmorphicSearchAndFilterBar: View {
    @Binding var searchText: String
    @Binding var selectedSortOption: HistoryView.SortOption
    @Binding var selectedMonth: String
    let availableMonths: [String]
    
    var body: some View {
        VStack(spacing: 16) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.7))
                
                TextField("Search receipts...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(.white)
                    .accentColor(.white)
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            )
            
            // Sort and Filter Options
            HStack(spacing: 16) {
                // Sort Picker
                Menu {
                    ForEach(HistoryView.SortOption.allCases, id: \.self) { option in
                        Button(option.rawValue) {
                            selectedSortOption = option
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.up.arrow.down")
                            .foregroundColor(.white)
                        
                        Text(selectedSortOption.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        Image(systemName: "chevron.down")
                            .foregroundColor(.white.opacity(0.7))
                            .font(.caption)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                
                // Month Filter
                Menu {
                    ForEach(availableMonths, id: \.self) { month in
                        Button(month) {
                            selectedMonth = month
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .foregroundColor(.white)
                        
                        Text(selectedMonth)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        Image(systemName: "chevron.down")
                            .foregroundColor(.white.opacity(0.7))
                            .font(.caption)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                
                Spacer()
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
        .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 8)
    }
}

// MARK: - Glassmorphic Receipts List
struct GlassmorphicReceiptsList: View {
    let receipts: [Receipt]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(receipts) { receipt in
                    NavigationLink(destination: ReceiptDetailView(receipt: receipt)) {
                        GlassmorphicReceiptCard(receipt: receipt)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
}

// MARK: - Glassmorphic Receipt Card
struct GlassmorphicReceiptCard: View {
    let receipt: Receipt
    
    var body: some View {
        HStack(spacing: 16) {
            // Store icon
            ZStack {
                Circle()
                    .fill(
                        SpendingCategory(rawValue: receipt.category ?? "Other")?.color.opacity(0.2) ?? Color.gray.opacity(0.2)
                    )
                    .frame(width: 56, height: 56)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                
                Image(systemName: SpendingCategory(rawValue: receipt.category ?? "Other")?.icon ?? "building.2")
                    .foregroundColor(SpendingCategory(rawValue: receipt.category ?? "Other")?.color ?? .gray)
                    .font(.system(size: 20, weight: .medium))
            }
            
            // Receipt details
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(receipt.storeName ?? "Unknown Store")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text("$\(String(format: "%.2f", receipt.totalAmount ?? 0))")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                        .shadow(color: .green.opacity(0.5), radius: 4)
                }
                
                if let date = formatReceiptDate(receipt) {
                    Text(date)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                HStack(spacing: 12) {
                    if let category = receipt.category {
                        Text(category)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                    }
                    
                    if let items = receipt.items, !items.isEmpty {
                        Text("\(items.count) items")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white.opacity(0.5))
                        .font(.caption)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 8)
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

// MARK: - Glassmorphic Empty History View
struct GlassmorphicEmptyHistoryView: View {
    let searchText: String
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 100, height: 100)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                
                if searchText.isEmpty {
                    Image(systemName: "receipt")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.7))
                } else {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            VStack(spacing: 12) {
                if searchText.isEmpty {
                    Text("No receipts yet")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("Scan your first receipt to get started")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                } else {
                    Text("No receipts found")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("Try adjusting your search or filters")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
            }
            
            Spacer()
        }
        .padding(40)
    }
}

// MARK: - Legacy Components (keeping for compatibility)
struct ReceiptRow: View {
    let receipt: Receipt
    
    var body: some View {
        HStack(spacing: 16) {
            // Store icon
            ZStack {
                Circle()
                    .fill(
                        SpendingCategory(rawValue: receipt.category ?? "Other")?.color.opacity(0.2) ?? Color.gray.opacity(0.2)
                    )
                    .frame(width: 56, height: 56)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                
                Image(systemName: SpendingCategory(rawValue: receipt.category ?? "Other")?.icon ?? "building.2")
                    .foregroundColor(SpendingCategory(rawValue: receipt.category ?? "Other")?.color ?? .gray)
                    .font(.system(size: 20, weight: .medium))
            }
            
            // Receipt details
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(receipt.storeName ?? "Unknown Store")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text("$\(String(format: "%.2f", receipt.totalAmount ?? 0))")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                        .shadow(color: .green.opacity(0.5), radius: 4)
                }
                
                if let date = formatReceiptDate(receipt) {
                    Text(date)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                HStack(spacing: 12) {
                    if let category = receipt.category {
                        Text(category)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                    }
                    
                    if let items = receipt.items, !items.isEmpty {
                        Text("\(items.count) items")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white.opacity(0.5))
                        .font(.caption)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 8)
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
