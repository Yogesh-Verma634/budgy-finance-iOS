//
//  HomeView.swift
//  budgyfinance
//
//  Created by Yogesh Verma on 25/12/24.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Monthly Overview")
                .font(.title2)
                .padding()

            HStack {
                VStack(alignment: .leading) {
                    Text("Spent")
                        .font(.headline)
                    Text("$0.00")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                }

                Spacer()

                VStack(alignment: .leading) {
                    Text("Remaining")
                        .font(.headline)
                    Text("$2,000.00")
                        .font(.largeTitle)
                        .foregroundColor(.green)
                }
            }
            .padding()

            ProgressView(value: 0.0, total: 1.0)
                .padding()

            Text("Insights")
                .font(.headline)
                .padding(.top)

            Text("You're on track with your budget! You have $2,000.00 left to spend this month.")
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)

            Spacer()
        }
        .padding()
    }
}
