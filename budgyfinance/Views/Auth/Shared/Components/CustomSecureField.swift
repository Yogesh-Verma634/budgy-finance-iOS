//
//  CustomSecureField.swift
//  budgyfinance
//
//  Created by Yogesh Verma on 29/12/24.
//


import SwiftUI

struct CustomSecureField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "lock")
                .foregroundColor(.gray)
            SecureField(placeholder, text: $text)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}