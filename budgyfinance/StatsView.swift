//
//  StatsView.swift
//  budgyfinance
//
//  Created by Yogesh Verma on 25/12/24.
//

import SwiftUI

struct StatsView: View {
    @State private var receipts: [Receipt] = []
    @State private var totalSpent: Double = 0.0
    @State private var isLoading = true

    var body: some View {
        VStack(alignment: .leading) {
            if isLoading {
                ProgressView("Loading analytics...")
            } else {
                Text("Spending Analytics")
                    .font(.title2)
                    .padding()

                HStack {
                    VStack(alignment: .leading) {
                        Text("This Month")
                            .font(.headline)
                        Text("$\(totalSpent, specifier: "%.2f")")
                            .font(.largeTitle)
                            .foregroundColor(.primary)
                    }

                    Spacer()

                    VStack(alignment: .trailing) {
                        Text("vs Last Month")
                            .font(.headline)
                        Text("+15%")
                            .font(.headline)
                            .foregroundColor(.red)
                    }
                }
                .padding()

                Text("Top Categories")
                    .font(.headline)
                    .padding(.horizontal)

                List {
                    HStack {
                        Text("Food")
                        Spacer()
                        Text("35%")
                            .foregroundColor(.blue)
                    }

                    HStack {
                        Text("Housing")
                        Spacer()
                        Text("28%")
                            .foregroundColor(.green)
                    }

                    HStack {
                        Text("Transport")
                        Spacer()
                        Text("20%")
                            .foregroundColor(.purple)
                    }
                }
                Spacer()
            }
        }
        .padding()
        .onAppear {
            fetchReceipts()
        }
    }

    private func fetchReceipts() {
        FirestoreManager.shared.fetchReceipts(forUser: "exampleUserId") { result in
            switch result {
            case .success(let fetchedReceipts):
                receipts = fetchedReceipts
                totalSpent = fetchedReceipts.reduce(0) { $0 + $1.totalAmount }
                isLoading = false
            case .failure(let error):
                print("Failed to fetch receipts: \(error.localizedDescription)")
                isLoading = false
            }
        }
    }
}
