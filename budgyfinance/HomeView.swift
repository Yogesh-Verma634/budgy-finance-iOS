//
//  HomeView.swift
//  budgyfinance
//
//  Created by Yogesh Verma on 25/12/24.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var firestoreManager: FirestoreManager
    @StateObject private var budgetManager = BudgetManager.shared
    @State private var receipts: [Receipt] = []
    @State private var showBudgetSheet = false
    @State private var isLoading = true
    @State private var categorySpending: [String: Double] = [:]
    @State private var showErrorAlert = false
    @State private var currentError: AppError?
    @State private var selectedTab = 0
    
    // Sort receipts by date for display
    private var sortedReceipts: [Receipt] {
        return receipts.sorted { (receipt1, receipt2) in
            let date1 = receipt1.parsedTransactionDateTime ?? receipt1.parsedReceiptDate ?? receipt1.scannedTime ?? Date.distantPast
            let date2 = receipt2.parsedTransactionDateTime ?? receipt2.parsedReceiptDate ?? receipt2.scannedTime ?? Date.distantPast
            return date1 > date2 // Most recent first
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Animated gradient background
                GlassmorphismBackground()
                
                ScrollView {
                    VStack(spacing: 16) {
                        if isLoading {
                            GlassmorphicLoadingView()
                        } else {
                            // Header with greeting
                            GlassmorphicHeaderSection(showBudgetSheet: $showBudgetSheet)
                            
                            // Budget Overview Card
                            GlassmorphicBudgetCard(
                                monthlyBudget: budgetManager.monthlyBudget,
                                currentSpent: budgetManager.currentMonthSpent,
                                remainingBudget: budgetManager.getRemainingBudget(),
                                progress: budgetManager.getBudgetProgress(),
                                status: budgetManager.getBudgetStatus()
                            )
                            
                            // Quick Actions
                            GlassmorphicQuickActionsSection()
                            
                            // Category Spending Chart
                            GlassmorphicCategoryCard(categorySpending: categorySpending)
                            
                            // Recent Transactions
                            GlassmorphicTransactionsCard(receipts: sortedReceipts)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .sheet(isPresented: $showBudgetSheet) {
                GlassmorphicBudgetSettingView()
            }
            .alert("Error", isPresented: $showErrorAlert) {
                Button("Retry") {
                    fetchData()
                }
                Button("OK", role: .cancel) { }
            } message: {
                Text(currentError?.localizedDescription ?? "Failed to load data. Please try again.")
            }
            .refreshable {
                fetchData()
            }
            .onAppear {
                fetchData()
            }
            .onChange(of: authViewModel.currentUser) {
                // your code here (if any)
            }
        }
    }
    
    private func fetchData() {
        guard let userId = authViewModel.currentUser?.uid else {
            print("HomeView: No user logged in - setting loading to false")
            DispatchQueue.main.async {
                self.isLoading = false
                self.receipts = []
                self.categorySpending = [:]
                self.budgetManager.currentMonthSpent = 0
            }
            return
        }
        
        print("HomeView: Fetching data for user: \(userId)")
        print("HomeView: User ID length: \(userId.count)")
        isLoading = true
        
        // Fetch budget
        budgetManager.fetchMonthlyBudget { error in
            if let error = error {
                print("HomeView: Error fetching budget: \(error.localizedDescription)")
            }
        }
        
        // Fetch receipts
        FirestoreManager.shared.fetchReceipts(forUser: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedReceipts):
                    print("HomeView: Successfully fetched \(fetchedReceipts.count) receipts")
                    self.receipts = fetchedReceipts
                    self.budgetManager.currentMonthSpent = self.budgetManager.calculateCurrentMonthSpent(receipts: fetchedReceipts)
                    self.categorySpending = self.calculateCategorySpending(receipts: fetchedReceipts)
                case .failure(let error):
                    print("HomeView: Failed to fetch receipts: \(error.localizedDescription)")
                    print("HomeView: Error details: \(error)")
                    self.receipts = []
                    self.categorySpending = [:]
                    self.budgetManager.currentMonthSpent = 0
                    
                    // Show error to user if it's not a network connectivity issue
                    if let firestoreError = error as? NSError, 
                       !firestoreError.localizedDescription.contains("network") {
                        self.currentError = .dataNotFound
                        self.showErrorAlert = true
                    }
                }
                self.isLoading = false
            }
        }
    }
    
    private func calculateCategorySpending(receipts: [Receipt]) -> [String: Double] {
        var spending: [String: Double] = [:]
        
        for receipt in receipts {
            let category = receipt.category ?? "Other"
            spending[category, default: 0] += receipt.totalAmount ?? 0
        }
        
        return spending
    }
}

// MARK: - Glassmorphism Background
struct GlassmorphismBackground: View {
    var body: some View {
        ZStack {
            // Static gradient background - no animation
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.3),
                    Color(red: 0.2, green: 0.1, blue: 0.4),
                    Color(red: 0.3, green: 0.2, blue: 0.5),
                    Color(red: 0.1, green: 0.3, blue: 0.4)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Static floating orbs for depth - no movement
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.purple.opacity(0.15), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 150
                    )
                )
                .frame(width: 300, height: 300)
                .offset(x: -100, y: -200)
                .blur(radius: 30)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.blue.opacity(0.1), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: 350, height: 350)
                .offset(x: 150, y: 300)
                .blur(radius: 40)
        }
    }
}

// MARK: - Glassmorphic Header Section
struct GlassmorphicHeaderSection: View {
    @Binding var showBudgetSheet: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Welcome back!")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("Let's track your spending")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                HStack(spacing: 16) {
                    // Budget button
                    Button(action: {
                        showBudgetSheet = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "dollarsign.circle.fill")
                                .foregroundColor(.white)
                                .font(.title2)
                            
                            Text("Budget")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    
                    // Profile avatar
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                        
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                }
            }
        }
        .padding(.top, 10)
    }
}

// MARK: - Glassmorphic Budget Card
struct GlassmorphicBudgetCard: View {
    let monthlyBudget: Double
    let currentSpent: Double
    let remainingBudget: Double
    let progress: Double
    let status: BudgetStatus
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Monthly Budget")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("Track your spending progress")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                // Status indicator
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color(status.color))
                        .frame(width: 10, height: 10)
                        .shadow(color: Color(status.color).opacity(0.5), radius: 4)
                    
                    Text(status.message)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
            }
            
            // Progress Ring
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 14)
                    .frame(width: 120, height: 120)
                
                // Progress circle
                Circle()
                    .trim(from: 0, to: min(progress, 1.0))
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(status.color),
                                Color(status.color).opacity(0.6),
                                Color(status.color).opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.5), value: progress)
                    .shadow(color: Color(status.color).opacity(0.5), radius: 10)
                
                // Center content
                VStack(spacing: 4) {
                    Text("\(Int(progress * 100))%")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Used")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            // Budget details
            HStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text("$\(String(format: "%.0f", currentSpent))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Spent")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    Text("$\(String(format: "%.0f", monthlyBudget))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Budget")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    Text("$\(String(format: "%.0f", remainingBudget))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                        .shadow(color: .green.opacity(0.5), radius: 4)
                    
                    Text("Remaining")
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

// MARK: - Glassmorphic Quick Actions Section
struct GlassmorphicQuickActionsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            HStack(spacing: 16) {
                // Scan Receipt Button
                NavigationLink(destination: CaptureButtonView()) {
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 56, height: 56)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                            
                            Image(systemName: "camera.fill")
                                .foregroundColor(.white)
                                .font(.title2)
                        }
                        
                        Text("Scan Receipt")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                // Manual Entry Button
                Button(action: {
                    // TODO: Implement manual entry
                }) {
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.green.opacity(0.3), Color.teal.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 56, height: 56)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                            
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.white)
                                .font(.title2)
                        }
                        
                        Text("Manual Entry")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                // View All Button
                NavigationLink(destination: HistoryView()) {
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.orange.opacity(0.3), Color.red.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 56, height: 56)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                            
                            Image(systemName: "list.bullet")
                                .foregroundColor(.white)
                                .font(.title2)
                        }
                        
                        Text("View All")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
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

// MARK: - Glassmorphic Category Card
struct GlassmorphicCategoryCard: View {
    let categorySpending: [String: Double]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Spending by Category")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                NavigationLink(destination: StatsView()) {
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
            
            if categorySpending.isEmpty {
                GlassmorphicEmptyStateView(
                    icon: "chart.pie",
                    title: "No spending data",
                    subtitle: "Scan your first receipt to see category breakdown"
                )
            } else {
                VStack(spacing: 16) {
                    ForEach(Array(categorySpending.sorted(by: { $0.value > $1.value }).prefix(5)), id: \.key) { category, amount in
                        GlassmorphicCategoryRow(
                            category: category,
                            amount: amount,
                            totalSpending: categorySpending.values.reduce(0, +)
                        )
                    }
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Glassmorphic Category Row
struct GlassmorphicCategoryRow: View {
    let category: String
    let amount: Double
    let totalSpending: Double
    
    private var percentage: Double {
        guard totalSpending > 0 else { return 0 }
        return amount / totalSpending
    }
    
    var body: some View {
        HStack(spacing: 20) {
            // Category icon
            ZStack {
                Circle()
                    .fill(
                        SpendingCategory(rawValue: category)?.color.opacity(0.2) ?? Color.gray.opacity(0.2)
                    )
                    .frame(width: 48, height: 48)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                
                Image(systemName: SpendingCategory(rawValue: category)?.icon ?? "circle.fill")
                    .foregroundColor(SpendingCategory(rawValue: category)?.color ?? .gray)
                    .font(.system(size: 18, weight: .medium))
            }
            
            // Category name and progress
            VStack(alignment: .leading, spacing: 8) {
                Text(category)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        SpendingCategory(rawValue: category)?.color ?? .gray,
                                        SpendingCategory(rawValue: category)?.color.opacity(0.6) ?? .gray.opacity(0.6)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * percentage, height: 6)
                    }
                }
                .frame(height: 6)
            }
            
            Spacer()
            
            // Amount
            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(String(format: "%.0f", amount))")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("\(Int(percentage * 100))%")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Glassmorphic Transactions Card
struct GlassmorphicTransactionsCard: View {
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
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Glassmorphic Transaction Row
struct GlassmorphicTransactionRow: View {
    let receipt: Receipt
    
    var body: some View {
        HStack(spacing: 20) {
            // Store icon
            ZStack {
                Circle()
                    .fill(
                        SpendingCategory(rawValue: receipt.category ?? "Other")?.color.opacity(0.2) ?? Color.gray.opacity(0.2)
                    )
                    .frame(width: 48, height: 48)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                
                Image(systemName: SpendingCategory(rawValue: receipt.category ?? "Other")?.icon ?? "building.2")
                    .foregroundColor(SpendingCategory(rawValue: receipt.category ?? "Other")?.color ?? .gray)
                    .font(.system(size: 18, weight: .medium))
            }
            
            // Store details
            VStack(alignment: .leading, spacing: 6) {
                Text(receipt.storeName ?? "Unknown Store")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                if let date = formatReceiptDate(receipt) {
                    Text(date)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                if let category = receipt.category {
                    Text(category)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
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
            }
            
            Spacer()
            
            // Amount
            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(String(format: "%.2f", receipt.totalAmount ?? 0))")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                // Item count
                if let items = receipt.items, !items.isEmpty {
                    Text("\(items.count) items")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
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

// MARK: - Glassmorphic Empty State View
struct GlassmorphicEmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                
                Image(systemName: icon)
                    .font(.system(size: 36))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(40)
    }
}

// MARK: - Glassmorphic Loading View
struct GlassmorphicLoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 100, height: 100)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
            
            Text("Loading your financial data...")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Glassmorphic Budget Setting View
struct GlassmorphicBudgetSettingView: View {
    @State private var budgetAmount: String = ""
    @StateObject private var budgetManager = BudgetManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        Color(red: 0.1, green: 0.1, blue: 0.3),
                        Color(red: 0.2, green: 0.1, blue: 0.4)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 36) {
                    // Header
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                            
                            Image(systemName: "dollarsign.circle.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 48))
                        }
                        
                        VStack(spacing: 12) {
                            Text("Set Monthly Budget")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Enter your monthly spending limit to track your expenses effectively")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    // Budget input
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Monthly Budget Amount")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        HStack {
                            Text("$")
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(.white.opacity(0.8))
                            
                            TextField("0.00", text: $budgetAmount)
                                .keyboardType(.decimalPad)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    
                    // Save button
                    Button(action: {
                        if let amount = Double(budgetAmount) {
                            budgetManager.setMonthlyBudget(amount) { error in
                                if error == nil {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }
                    }) {
                        Text("Save Budget")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        budgetAmount.isEmpty || Double(budgetAmount) == nil
                                        ? LinearGradient(
                                            colors: [Color.white.opacity(0.3), Color.white.opacity(0.3)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                        : LinearGradient(
                                            colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                    .disabled(budgetAmount.isEmpty || Double(budgetAmount) == nil)
                    
                    Spacer()
                }
                .padding(28)
            }
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }
            .foregroundColor(.white))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Legacy Components (keeping for compatibility)
struct BudgetOverviewCard: View {
    let monthlyBudget: Double
    let currentSpent: Double
    let remainingBudget: Double
    let progress: Double
    let status: BudgetStatus
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Monthly Overview")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Spent")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("$\(String(format: "%.2f", currentSpent))")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    Text("Remaining")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("$\(String(format: "%.2f", remainingBudget))")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }
            
            VStack(spacing: 8) {
                HStack {
                    Text("Budget Progress")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(Int(progress * 100))%")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(status.color)))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
            }
            
            HStack {
                Image(systemName: status == .good ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .foregroundColor(Color(status.color))
                Text(status.message)
                    .font(.subheadline)
                    .foregroundColor(Color(status.color))
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct CategorySpendingCard: View {
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

struct RecentTransactionsCard: View {
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

struct BudgetSettingView: View {
    @State private var budgetAmount: String = ""
    @StateObject private var budgetManager = BudgetManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Set Monthly Budget")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Enter your monthly spending limit to track your expenses")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                TextField("Enter amount", text: $budgetAmount)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button("Save Budget") {
                    if let amount = Double(budgetAmount) {
                        budgetManager.setMonthlyBudget(amount) { error in
                            if error == nil {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(budgetAmount.isEmpty || Double(budgetAmount) == nil)
                
                Spacer()
            }
            .padding()
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
