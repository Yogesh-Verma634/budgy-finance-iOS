import SwiftUI

struct TermsOfServiceView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    termsContent
                }
                .padding()
            }
            .navigationTitle("Terms of Service")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
    }
    
    private var termsContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Terms of Service for BudgyFinance")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Last updated: January 17, 2025")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Group {
                SectionView(title: "Acceptance of Terms") {
                    Text("By downloading, installing, or using the BudgyFinance mobile application, you agree to be bound by these Terms of Service. If you do not agree to these Terms, do not use the Service.")
                }
                
                SectionView(title: "Description of Service") {
                    Text("BudgyFinance is a personal finance and budgeting application that helps users:")
                    Text("• Track expenses by scanning and processing receipt images\n• Set and monitor budget goals\n• Categorize spending and analyze financial habits\n• Store and synchronize financial data across devices")
                }
                
                SectionView(title: "Eligibility") {
                    Text("**Age Requirements**")
                        .fontWeight(.semibold)
                    Text("• You must be at least 13 years old to use this Service\n• Users under 18 must have parental or guardian consent\n• You must have legal capacity to enter binding agreements")
                    
                    Text("**Account Requirements**")
                        .fontWeight(.semibold)
                        .padding(.top, 8)
                    Text("• Provide accurate and complete information\n• Maintain confidentiality of your account credentials\n• Notify us immediately of any unauthorized use")
                }
                
                SectionView(title: "Acceptable Use") {
                    Text("**Permitted Uses**")
                        .fontWeight(.semibold)
                    Text("• Personal, non-commercial expense tracking and budgeting\n• Processing your own receipts and financial documents\n• Managing your personal financial information")
                    
                    Text("**Prohibited Uses**")
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                        .padding(.top, 8)
                    Text("• Violate laws or infringe on others' rights\n• Process receipts that don't belong to you\n• Reverse engineer or hack the application\n• Share account credentials with others\n• Use for commercial purposes without permission")
                        .foregroundColor(.red)
                }
                
                SectionView(title: "Receipt Processing") {
                    Text("• Receipt images are processed using third-party AI services (OpenAI)\n• Processing may not be 100% accurate - please review all data\n• You are responsible for verifying extracted transaction information\n• We are not liable for financial decisions based on processed data")
                }
                
                SectionView(title: "Financial Disclaimer") {
                    Text("**Important Notice**")
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                    Text("• BudgyFinance is a budgeting tool and does not provide financial advice\n• We are not a financial institution or certified advisor\n• Consult qualified professionals for financial planning\n• We do not guarantee accuracy of processed data")
                        .foregroundColor(.orange)
                }
                
                SectionView(title: "Service Availability") {
                    Text("• We strive for reliable service but do not guarantee 100% uptime\n• Service may be temporarily unavailable for maintenance\n• We may modify or discontinue features with reasonable notice\n• Available in regions where Apple App Store operates")
                }
                
                SectionView(title: "Limitation of Liability") {
                    Text("TO THE MAXIMUM EXTENT PERMITTED BY LAW:")
                        .fontWeight(.semibold)
                    Text("• The Service is provided \"AS IS\" without warranties\n• We are not liable for indirect or consequential damages\n• We are not liable for financial losses from Service use\n• Our total liability is limited to the amount you paid")
                }
                
                SectionView(title: "Contact Information") {
                    Text("For questions about these Terms:")
                    Text("Email: support@budgyfinance.com")
                        .foregroundColor(.blue)
                }
            }
            
            Divider()
                .padding(.vertical)
            
            Text("By using BudgyFinance, you acknowledge that you have read, understood, and agree to be bound by these Terms of Service.")
                .font(.footnote)
                .foregroundColor(.secondary)
                .italic()
        }
    }
}

#Preview {
    TermsOfServiceView()
}
