//
//  HomeView.swift
//  budgyfinance
//
//  Created by Yogesh Verma on 25/12/24.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var budgetManager = BudgetManager.shared
    @State private var receipts: [Receipt] = []
    @State private var showBudgetSheet = false
    @State private var isLoading = true
    @State private var categorySpending: [String: Double] = [:]
    @State private var showErrorAlert = false
    @State private var currentError: AppError?
    
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
            ScrollView {
                VStack(spacing: 20) {
                    if isLoading {
                        ProgressView("Loading...")
                            .padding()
                    } else {
                        // Budget Overview Card
                        BudgetOverviewCard(
                            monthlyBudget: budgetManager.monthlyBudget,
                            currentSpent: budgetManager.currentMonthSpent,
                            remainingBudget: budgetManager.getRemainingBudget(),
                            progress: budgetManager.getBudgetProgress(),
                            status: budgetManager.getBudgetStatus()
                        )
                        
                        // Category Spending Chart
                        CategorySpendingCard(categorySpending: categorySpending)
                        
                        // Recent Transactions
                        RecentTransactionsCard(receipts: sortedReceipts)
                    }
                }
                .padding()
            }
            .navigationTitle("Home")
            .navigationBarItems(trailing: Button("Set Budget") {
                showBudgetSheet = true
            })
            .sheet(isPresented: $showBudgetSheet) {
                BudgetSettingView()
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
