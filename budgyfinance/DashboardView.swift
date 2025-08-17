import SwiftUI
import Charts
import FirebaseAuth

struct DashboardView: View {
    @State private var receipts: [Receipt] = []
    @State private var isLoading = false
    @State private var monthlyGoal: Double = 1000.0
    
    // Sort receipts by date for display
    private var sortedReceipts: [Receipt] {
        return receipts.sorted { (receipt1, receipt2) in
            let date1 = receipt1.parsedTransactionDateTime ?? receipt1.parsedReceiptDate ?? receipt1.scannedTime ?? Date.distantPast
            let date2 = receipt2.parsedTransactionDateTime ?? receipt2.parsedReceiptDate ?? receipt2.scannedTime ?? Date.distantPast
            return date1 > date2 // Most recent first
        }
    }
    
    // Helper method to format receipt date for chart display
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
                formatter.dateFormat = "MM/dd"
            } else {
                // Time is available, show both date and time
                formatter.dateFormat = "MM/dd HH:mm"
            }
            return formatter.string(from: parsedDateTime)
        } else if let scannedTime = receipt.scannedTime {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd"
            return formatter.string(from: scannedTime)
        } else {
            return receipt.date ?? "Unknown"
        }
    }

    var totalSpent: Double {
        receipts.reduce(0) { $0 + ($1.totalAmount ?? 0.0) }
    }

    var remainingBudget: Double {
        monthlyGoal - totalSpent
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    if isLoading {
                        ProgressView("Loading...")
                            .padding()
                    } else if receipts.isEmpty {
                        VStack {
                            Text("No receipts found.")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Button(action: {
                                DispatchQueue.main.async {
                                    if let userId = Auth.auth().currentUser?.uid {
                                        fetchReceipts(forUser: userId)
                                    }
                                }
                            })
                            {
                                Text("Refresh")
                                    .font(.subheadline)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                        .padding()
                    } else {
                        VStack(spacing: 20) {
                            Text("Spending Overview")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            VStack(spacing: 16) {
                                MetricCard(title: "Total Spent This Month", value: String(format: "$%.2f", totalSpent), iconName: "cart.fill", color: .orange)
                                MetricCard(title: "Remaining Budget", value: String(format: "$%.2f", remainingBudget), iconName: "dollarsign.circle.fill", color: remainingBudget >= 0 ? .green : .red)
                            }

                            Text("Spending Chart")
                                .font(.title2)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top)

                            Chart {
                                ForEach(sortedReceipts, id: \.id) { receipt in
                                    BarMark(
                                        x: .value("Date", formatReceiptDate(receipt)),
                                        y: .value("Amount", receipt.totalAmount ?? 0.0)
                                    )
                                    .foregroundStyle(by: .value("Store", receipt.storeName ?? "Other"))
                                }
                            }
                            .chartYAxis {
                                AxisMarks(position: .leading)
                            }
                            .frame(height: 300)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)

                            
                            VStack(alignment: .leading) {
                                Text("Set your monthly goal below:")
                                    .font(.subheadline)
                                
                                HStack {
                                    Text("Monthly Goal:")
                                    TextField(
                                        "Enter goal",
                                        value: $monthlyGoal,
                                        format: .currency(code: "USD")
                                    )
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)

                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationBarTitle("Dashboard", displayMode: .inline)
            .onAppear {
                if let userId = Auth.auth().currentUser?.uid {
                    fetchReceipts(forUser: userId)
                } else {
                    print("No authenticated user found.")
                }
            }
            .refreshable {
                if let userId = Auth.auth().currentUser?.uid {
                    fetchReceipts(forUser: userId)
                } else {
                    print("No authenticated user found.")
                }
            }
        }
    }

    private func fetchReceipts(forUser userId: String) {
        if !receipts.isEmpty && !isLoading {
            // Use cached data if available and not loading
            return
        }

        isLoading = true
        FirestoreManager.shared.fetchReceipts(forUser: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedReceipts):
                    self.receipts = fetchedReceipts
                    // Cache the fetched data locally if required
                case .failure(let error):
                    print("Error fetching receipts for user \(userId): \(error.localizedDescription)")
                    self.receipts = []
                }
                self.isLoading = false
            }
        }
    }
}
