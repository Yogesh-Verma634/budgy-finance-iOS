//
//  StatsView.swift
//  budgyfinance
//
//  Created by Yogesh Verma on 25/12/24.
//

import SwiftUI
import Charts

struct StatsView: View {
    @FetchRequest(fetchRequest: Receipt.fetchAll()) var receipts: FetchedResults<Receipt>

    var totalSpent: Double {
        receipts.reduce(0) { $0 + $1.totalAmount }
    }

    var body: some View {
        VStack(alignment: .leading) {
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
        .padding()
    }
}
