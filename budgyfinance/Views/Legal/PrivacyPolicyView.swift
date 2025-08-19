import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    privacyPolicyContent
                }
                .padding()
            }
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
    }
    
    private var privacyPolicyContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Privacy Policy for BudgyFinance")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Last updated: January 17, 2025")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Group {
                SectionView(title: "Introduction") {
                    Text("BudgyFinance (\"we,\" \"our,\" or \"us\") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application and related services (the \"Service\").")
                }
                
                SectionView(title: "Information We Collect") {
                    Text("**Personal Information**")
                        .fontWeight(.semibold)
                    Text("• Account Information: Email address, name, and authentication credentials\n• Receipt Data: Images of receipts, extracted text, and transaction information\n• Budget Information: Your budget goals, spending categories, and preferences")
                    
                    Text("**Automatically Collected Information**")
                        .fontWeight(.semibold)
                        .padding(.top, 8)
                    Text("• Device Information: Device type, OS version, unique identifiers\n• Usage Data: App usage statistics, feature usage, crash reports\n• Log Information: Error logs, performance data, debugging information")
                }
                
                SectionView(title: "How We Use Your Information") {
                    Text("**Core App Functionality**")
                        .fontWeight(.semibold)
                    Text("• Receipt Processing: Extract text and transaction data using AI\n• Budget Tracking: Calculate spending and track budget progress\n• Data Synchronization: Sync your data across devices\n• Account Management: Maintain your account and provide support")
                }
                
                SectionView(title: "Third-Party Services") {
                    Text("We use these third-party services:")
                    Text("• **Firebase (Google)**: Cloud storage, authentication, and database\n• **OpenAI**: AI-powered text extraction from receipt images\n• **Apple Services**: App Store, TestFlight, and iOS system services")
                }
                
                SectionView(title: "Data Security") {
                    Text("• **Encryption**: All data is encrypted during transmission\n• **Secure Storage**: Enterprise-grade security with Firebase\n• **Access Controls**: Limited access on need-to-know basis\n• **Regular Updates**: Continuous security monitoring and updates")
                }
                
                SectionView(title: "Your Privacy Rights") {
                    Text("You have the right to:")
                    Text("• **View Your Data**: Access all personal information we have\n• **Update Information**: Modify or correct your account information\n• **Delete Account**: Request deletion of your account and data\n• **Data Export**: Download a copy of your data")
                }
                
                SectionView(title: "Contact Us") {
                    Text("If you have questions about this Privacy Policy:")
                    Text("Email: support@budgyfinance.com")
                        .foregroundColor(.blue)
                }
            }
            
            Divider()
                .padding(.vertical)
            
            Text("By using BudgyFinance, you acknowledge that you have read and understood this Privacy Policy and agree to the collection and use of information in accordance with this policy.")
                .font(.footnote)
                .foregroundColor(.secondary)
                .italic()
        }
    }
}

struct SectionView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            content
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    PrivacyPolicyView()
}
