//
//  CustomSecureField.swift
//  budgyfinance
//
//  Created by Yogesh Verma on 29/12/24.
//


import SwiftUI

struct CustomSecureField: View {
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        SecureField(placeholder, text: $text)
            .textFieldStyle(RoundedBorderTextFieldStyle())
    }
}