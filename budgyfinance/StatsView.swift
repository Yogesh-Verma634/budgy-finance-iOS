import SwiftUI

struct StatsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var receipts: [Receipt] = []
    @State private var totalSpent: Double = 0.0
    @State private var monthlySpent: Double = 0.0
    @State private var highestExpense: Double = 0.0
    @State private var mostFrequentStore: String = "N/A"
    @State private var isLoading = true
    @State private var categorySpending: [String: Double] = [:]
    @State private var monthlyTrends: [String: Double] = [:]
    @State private var selectedTimeFrame: TimeFrame = .month
    
    // Sort receipts by date for display
    private var sortedReceipts: [Receipt] {
        return receipts.sorted { (receipt1, receipt2) in
            let date1 = receipt1.parsedTransactionDateTime ?? receipt1.parsedReceiptDate ?? receipt1.scannedTime ?? Date.distantPast
            let date2 = receipt2.parsedTransactionDateTime ?? receipt2.parsedReceiptDate ?? receipt2.scannedTime ?? Date.distantPast
            return date1 > date2 // Most recent first
        }
    }

    enum TimeFrame: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if isLoading {
                        ProgressView("Loading analytics...")
                            .padding()
                    } else {
                        // Time Frame Selector
                        Picker("Time Frame", selection: $selectedTimeFrame) {
                            ForEach(TimeFrame.allCases, id: \.self) { timeFrame in
                                Text(timeFrame.rawValue).tag(timeFrame)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        
                        Text("Spending Analytics")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.horizontal)

                        // Key Metrics Summary
                        VStack(spacing: 16) {
                            MetricCard(title: "Total Spent", value: "$\(String(format: "%.2f", totalSpent))", iconName: "dollarsign.circle.fill", color: .green)
                            MetricCard(title: "This \(selectedTimeFrame.rawValue)", value: "$\(String(format: "%.2f", monthlySpent))", iconName: "calendar.circle.fill", color: .blue)
                            MetricCard(title: "Highest Expense", value: "$\(String(format: "%.2f", highestExpense))", iconName: "arrow.up.circle.fill", color: .orange)
                        }
                        .padding(.horizontal)

                        // Category Spending Chart
                        CategorySpendingChart(categorySpending: categorySpending)
                        
                        // Monthly Trends
                        MonthlyTrendsChart(monthlyTrends: monthlyTrends, timeFrame: selectedTimeFrame)
                        
                        // Spending Insights
                        SpendingInsightsCard(
                            mostFrequentStore: mostFrequentStore,
                            averageSpending: calculateAverageSpending(),
                            topCategory: getTopCategory()
                        )
                        
                        // Recent Transactions
                        RecentTransactionsSection(receipts: sortedReceipts)
                    }
                }
            }
            .refreshable {
                fetchReceipts()
            }
            .onAppear {
                fetchReceipts()
            }
            .onChange(of: selectedTimeFrame) {
                calculateAnalytics()
            }
            .onChange(of: authViewModel.currentUser) {
                fetchReceipts()
            }
        }
    }

    private func fetchReceipts() {
        guard let userId = authViewModel.currentUser?.uid else {
            print("No user logged in - setting loading to false")
            DispatchQueue.main.async {
                self.isLoading = false
                self.receipts = []
                self.totalSpent = 0.0
                self.monthlySpent = 0.0
                self.highestExpense = 0.0
                self.mostFrequentStore = "N/A"
                self.categorySpending = [:]
                self.monthlyTrends = [:]
            }
            return
        }

        print("Fetching receipts for user: \(userId)")
        FirestoreManager.shared.fetchReceipts(forUser: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedReceipts):
                    print("Successfully fetched \(fetchedReceipts.count) receipts for stats")
                    receipts = fetchedReceipts
                    calculateAnalytics()
                case .failure(let error):
                    print("Failed to fetch receipts: \(error.localizedDescription)")
                    receipts = []
                    totalSpent = 0.0
                    monthlySpent = 0.0
                    highestExpense = 0.0
                    mostFrequentStore = "N/A"
                    categorySpending = [:]
                    monthlyTrends = [:]
                }
                isLoading = false
            }
        }
    }
    
    private func calculateAnalytics() {
        totalSpent = receipts.reduce(0) { $0 + ($1.totalAmount ?? 0) }
        monthlySpent = calculateTimeFrameSpent(receipts: receipts, timeFrame: selectedTimeFrame)
        highestExpense = receipts.map { $0.totalAmount ?? 0 }.max() ?? 0
        mostFrequentStore = calculateMostFrequentStore(receipts: receipts)
        categorySpending = calculateCategorySpending(receipts: receipts)
        monthlyTrends = calculateMonthlyTrends(receipts: receipts, timeFrame: selectedTimeFrame)
    }

    private func calculateTimeFrameSpent(receipts: [Receipt], timeFrame: TimeFrame) -> Double {
        let calendar = Calendar.current
        let now = Date()
        
        return receipts.filter { receipt in
            let receiptDate = receipt.parsedTransactionDateTime ?? receipt.parsedReceiptDate ?? receipt.scannedTime
            guard let date = receiptDate else { return false }
            
            switch timeFrame {
            case .week:
                return calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear)
            case .month:
                return calendar.isDate(date, equalTo: now, toGranularity: .month)
            case .year:
                return calendar.isDate(date, equalTo: now, toGranularity: .year)
            }
        }
        .reduce(0) { $0 + ($1.totalAmount ?? 0) }
    }

    private func calculateMostFrequentStore(receipts: [Receipt]) -> String {
        let storeCounts: [String: Int] = receipts.reduce(into: [:]) { counts, receipt in
            if let store = receipt.storeName {
                counts[store, default: 0] += 1
            }
        }
        return storeCounts.max(by: { $0.value < $1.value })?.key ?? "N/A"
    }
    
    private func calculateCategorySpending(receipts: [Receipt]) -> [String: Double] {
        var spending: [String: Double] = [:]
        
        for receipt in receipts {
            let category = receipt.category ?? "Other"
            spending[category, default: 0] += receipt.totalAmount ?? 0
        }
        
        return spending
    }
    
    private func calculateMonthlyTrends(receipts: [Receipt], timeFrame: TimeFrame) -> [String: Double] {
        var trends: [String: Double] = [:]
        let calendar = Calendar.current
        let now = Date()
        
        for receipt in receipts {
            let receiptDate = receipt.parsedTransactionDateTime ?? receipt.parsedReceiptDate ?? receipt.scannedTime
            guard let date = receiptDate else { continue }
            
            let formatter = DateFormatter()
            switch timeFrame {
            case .week:
                formatter.dateFormat = "EEE"
            case .month:
                formatter.dateFormat = "MMM dd"
            case .year:
                formatter.dateFormat = "MMM"
            }
            
            let key = formatter.string(from: date)
            trends[key, default: 0] += receipt.totalAmount ?? 0
        }
        
        return trends
    }
    
    private func calculateAverageSpending() -> Double {
        guard !receipts.isEmpty else { return 0 }
        return totalSpent / Double(receipts.count)
    }
    
    private func getTopCategory() -> String {
        return categorySpending.max(by: { $0.value < $1.value })?.key ?? "N/A"
    }


}

struct CategorySpendingChart: View {
    let categorySpending: [String: Double]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Spending by Category")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            if categorySpending.isEmpty {
                Text("No spending data available")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                VStack(spacing: 12) {
                    ForEach(Array(categorySpending.sorted(by: { $0.value > $1.value })), id: \.key) { category, amount in
                        CategorySpendingRow(category: category, amount: amount, total: categorySpending.values.reduce(0, +))
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct CategorySpendingRow: View {
    let category: String
    let amount: Double
    let total: Double
    
    private var percentage: Double {
        guard total > 0 else { return 0 }
        return amount / total
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: SpendingCategory(rawValue: category)?.icon ?? "circle.fill")
                    .foregroundColor(SpendingCategory(rawValue: category)?.color ?? .gray)
                    .frame(width: 20)
                
                Text(category)
                    .font(.subheadline)
                
                Spacer()
                
                Text("$\(String(format: "%.2f", amount))")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(SpendingCategory(rawValue: category)?.color ?? .gray)
                        .frame(width: geometry.size.width * percentage, height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
    }
}

struct MonthlyTrendsChart: View {
    let monthlyTrends: [String: Double]
    let timeFrame: StatsView.TimeFrame
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("\(timeFrame.rawValue)ly Trends")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            if monthlyTrends.isEmpty {
                Text("No trend data available")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                VStack(spacing: 12) {
                    ForEach(Array(monthlyTrends.sorted(by: { $0.key < $1.key })), id: \.key) { period, amount in
                        HStack {
                            Text(period)
                                .font(.subheadline)
                                .frame(width: 60, alignment: .leading)
                            
                            Spacer()
                            
                            Text("$\(String(format: "%.2f", amount))")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .padding(.vertical)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct SpendingInsightsCard: View {
    let mostFrequentStore: String
    let averageSpending: Double
    let topCategory: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Spending Insights")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                InsightRow(title: "Most Frequent Store", value: mostFrequentStore, icon: "building.2.fill")
                InsightRow(title: "Average Transaction", value: "$\(String(format: "%.2f", averageSpending))", icon: "chart.bar.fill")
                InsightRow(title: "Top Category", value: topCategory, icon: "star.fill")
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct InsightRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
    }
}

struct RecentTransactionsSection: View {
    let receipts: [Receipt]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Transactions")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)

            if receipts.isEmpty {
                Text("No recent transactions")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                VStack(spacing: 12) {
                    ForEach(receipts.prefix(5)) { receipt in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(receipt.storeName ?? "Unknown Store")
                                    .font(.headline)
                                if let date = formatReceiptDate(receipt) {
                                    Text(date)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("$\(String(format: "%.2f", receipt.totalAmount ?? 0.0))")
                                    .font(.headline)
                                    .foregroundColor(.green)
                                if let category = receipt.category {
                                    Text(category)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                }
            }
        }
        .padding(.vertical)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
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
