import SwiftUI

// MARK: - Glassmorphism Background (using from HomeView.swift)

struct StatsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var firestoreManager: FirestoreManager
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
            ZStack {
                // Animated gradient background
                GlassmorphismBackground()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if isLoading {
                            GlassmorphicLoadingView()
                        } else {
                            // Header
                            GlassmorphicStatsHeader()
                            
                            // Time Frame Selector
                            GlassmorphicTimeFrameSelector(selectedTimeFrame: $selectedTimeFrame)
                            
                            // Key Metrics Summary
                            GlassmorphicMetricsGrid(
                                totalSpent: totalSpent,
                                monthlySpent: monthlySpent,
                                highestExpense: highestExpense,
                                timeFrame: selectedTimeFrame
                            )

                            // Category Spending Chart
                            GlassmorphicCategoryChart(categorySpending: categorySpending)
                            
                            // Monthly Trends
                            GlassmorphicTrendsChart(monthlyTrends: monthlyTrends, timeFrame: selectedTimeFrame)
                            
                            // Spending Insights
                            GlassmorphicInsightsCard(
                                mostFrequentStore: mostFrequentStore,
                                averageSpending: calculateAverageSpending(),
                                topCategory: getTopCategory()
                            )
                            
                            // Recent Transactions
                            GlassmorphicTransactionsSection(receipts: sortedReceipts)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
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
        guard !receipts.isEmpty else { return 0.0 }
        return totalSpent / Double(receipts.count)
    }
    
    private func getTopCategory() -> String {
        let categorySpending = calculateCategorySpending(receipts: receipts)
        return categorySpending.max(by: { $0.value < $1.value })?.key ?? "N/A"
    }
}

// MARK: - Glassmorphic Stats Header
struct GlassmorphicStatsHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Spending Analytics")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Track your financial patterns")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                // Analytics icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                    
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(.white)
                        .font(.title2)
                }
            }
        }
        .padding(.top, 10)
    }
}

// MARK: - Glassmorphic Time Frame Selector
struct GlassmorphicTimeFrameSelector: View {
    @Binding var selectedTimeFrame: StatsView.TimeFrame
    
    private func backgroundFill(for timeFrame: StatsView.TimeFrame) -> AnyShapeStyle {
        if selectedTimeFrame == timeFrame {
            return AnyShapeStyle(
                LinearGradient(
                    colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        } else {
            return AnyShapeStyle(Color.white.opacity(0.1))
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Time Period")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            HStack(spacing: 12) {
                ForEach(StatsView.TimeFrame.allCases, id: \.self) { timeFrame in
                    Button(action: {
                        selectedTimeFrame = timeFrame
                    }) {
                        Text(timeFrame.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(selectedTimeFrame == timeFrame ? .white : .white.opacity(0.7))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(backgroundFill(for: timeFrame))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
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
}

// MARK: - Glassmorphic Metrics Grid
struct GlassmorphicMetricsGrid: View {
    let totalSpent: Double
    let monthlySpent: Double
    let highestExpense: Double
    let timeFrame: StatsView.TimeFrame
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                GlassmorphicMetricCard(
                    title: "Total Spent",
                    value: "$\(String(format: "%.0f", totalSpent))",
                    iconName: "dollarsign.circle.fill",
                    color: .green
                )
                
                GlassmorphicMetricCard(
                    title: "This \(timeFrame.rawValue)",
                    value: "$\(String(format: "%.0f", monthlySpent))",
                    iconName: "calendar.circle.fill",
                    color: .blue
                )
            }
            
            GlassmorphicMetricCard(
                title: "Highest Expense",
                value: "$\(String(format: "%.0f", highestExpense))",
                iconName: "arrow.up.circle.fill",
                color: .orange
            )
        }
    }
}

// MARK: - Glassmorphic Metric Card
struct GlassmorphicMetricCard: View {
    let title: String
    let value: String
    let iconName: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 48, height: 48)
                        .overlay(
                            Circle()
                                .stroke(color.opacity(0.4), lineWidth: 1)
                        )
                    
                    Image(systemName: iconName)
                        .foregroundColor(color)
                        .font(.title2)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(value)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
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
}

// MARK: - Glassmorphic Category Chart
struct GlassmorphicCategoryChart: View {
    let categorySpending: [String: Double]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Spending by Category")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            if categorySpending.isEmpty {
                GlassmorphicEmptyStateView(
                    icon: "chart.pie",
                    title: "No category data",
                    subtitle: "Scan receipts to see spending breakdown"
                )
            } else {
                VStack(spacing: 16) {
                    ForEach(Array(categorySpending.sorted(by: { $0.value > $1.value })), id: \.key) { category, amount in
                        GlassmorphicCategoryRow(
                            category: category,
                            amount: amount,
                            totalSpending: categorySpending.values.reduce(0, +)
                        )
                    }
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
}

// MARK: - Glassmorphic Category Row (using from HomeView.swift)

// MARK: - Glassmorphic Trends Chart
struct GlassmorphicTrendsChart: View {
    let monthlyTrends: [String: Double]
    let timeFrame: StatsView.TimeFrame
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Spending Trends")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(timeFrame.rawValue)ly Pattern")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
            }
            
            if monthlyTrends.isEmpty {
                GlassmorphicEmptyStateView(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "No trend data",
                    subtitle: "Not enough data to show patterns"
                )
            } else {
                // Simple bar chart representation
                VStack(spacing: 12) {
                    ForEach(Array(monthlyTrends.sorted(by: { $0.value > $1.value }).prefix(8)), id: \.key) { period, amount in
                        HStack(spacing: 12) {
                            Text(period)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                                .frame(width: 60, alignment: .leading)
                            
                            // Bar
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.white.opacity(0.1))
                                        .frame(height: 20)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 4)
                                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                        )
                                    
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(
                                            width: geometry.size.width * min(amount / (monthlyTrends.values.max() ?? 1), 1.0),
                                            height: 20
                                        )
                                }
                            }
                            .frame(height: 20)
                            
                            Text("$\(String(format: "%.0f", amount))")
                                .font(.caption)
                                .foregroundColor(.white)
                                .frame(width: 50, alignment: .trailing)
                        }
                    }
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
}

// MARK: - Glassmorphic Insights Card
struct GlassmorphicInsightsCard: View {
    let mostFrequentStore: String
    let averageSpending: Double
    let topCategory: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Spending Insights")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                    .font(.title2)
            }
            
            VStack(spacing: 16) {
                GlassmorphicInsightRow(
                    icon: "building.2.fill",
                    title: "Most Visited Store",
                    value: mostFrequentStore,
                    color: .blue
                )
                
                GlassmorphicInsightRow(
                    icon: "chart.bar.fill",
                    title: "Average Transaction",
                    value: "$\(String(format: "%.2f", averageSpending))",
                    color: .green
                )
                
                GlassmorphicInsightRow(
                    icon: "tag.fill",
                    title: "Top Category",
                    value: topCategory,
                    color: .purple
                )
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
}

// MARK: - Glassmorphic Insight Row
struct GlassmorphicInsightRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Circle()
                            .stroke(color.opacity(0.4), lineWidth: 1)
                    )
                
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 16, weight: .medium))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Glassmorphic Transactions Section
struct GlassmorphicTransactionsSection: View {
    let receipts: [Receipt]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Recent Transactions")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                NavigationLink(destination: HistoryView()) {
                    Text("View All")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                )
                        )
                }
            }
            
            if receipts.isEmpty {
                GlassmorphicEmptyStateView(
                    icon: "receipt",
                    title: "No transactions yet",
                    subtitle: "Scan your first receipt to get started"
                )
            } else {
                VStack(spacing: 12) {
                    ForEach(receipts.prefix(5)) { receipt in
                        GlassmorphicTransactionRow(receipt: receipt)
                    }
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
}

// MARK: - Glassmorphic Transaction Row (using from HomeView.swift)

// MARK: - Glassmorphic Empty State View (using from HomeView.swift)

// MARK: - Glassmorphic Loading View (using from HomeView.swift)

// MARK: - Legacy Components (using MetricCard from MetricCard.swift)

struct CategorySpendingChart: View {
    let categorySpending: [String: Double]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Spending by Category")
                .font(.title2)
                .fontWeight(.bold)
            
            if categorySpending.isEmpty {
                Text("No spending data available")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                VStack(spacing: 12) {
                    ForEach(Array(categorySpending.sorted(by: { $0.value > $1.value })), id: \.key) { category, amount in
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
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct MonthlyTrendsChart: View {
    let monthlyTrends: [String: Double]
    let timeFrame: StatsView.TimeFrame
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Monthly Trends")
                .font(.title2)
                .fontWeight(.bold)
            
            if monthlyTrends.isEmpty {
                Text("No trend data available")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                Text("Trend data for \(timeFrame.rawValue)")
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
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
            
            VStack(spacing: 12) {
                HStack {
                    Text("Most Frequent Store:")
                        .font(.subheadline)
                    Spacer()
                    Text(mostFrequentStore)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("Average Spending:")
                        .font(.subheadline)
                    Spacer()
                    Text("$\(String(format: "%.2f", averageSpending))")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("Top Category:")
                        .font(.subheadline)
                    Spacer()
                    Text(topCategory)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct RecentTransactionsSection: View {
    let receipts: [Receipt]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Transactions")
                .font(.title2)
                .fontWeight(.bold)
            
            if receipts.isEmpty {
                Text("No recent transactions")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                VStack(spacing: 12) {
                    ForEach(receipts.prefix(5)) { receipt in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(receipt.storeName ?? "Unknown Store")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                if let date = formatReceiptDate(receipt) {
                                    Text(date)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("$\(String(format: "%.2f", receipt.totalAmount ?? 0))")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.green)
                                
                                if let category = receipt.category {
                                    Text(category)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
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

