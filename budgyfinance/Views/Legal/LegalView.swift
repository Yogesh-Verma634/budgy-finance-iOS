import SwiftUI

struct LegalView: View {
    @State private var showPrivacyPolicy = false
    @State private var showTermsOfService = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Legal Information")) {
                    LegalRowView(
                        title: "Privacy Policy",
                        subtitle: "How we collect and use your data",
                        icon: "lock.shield"
                    ) {
                        showPrivacyPolicy = true
                    }
                    
                    LegalRowView(
                        title: "Terms of Service",
                        subtitle: "Terms and conditions for using the app",
                        icon: "doc.text"
                    ) {
                        showTermsOfService = true
                    }
                }
                
                Section(header: Text("App Information")) {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                            .frame(width: 24, height: 24)
                        
                        VStack(alignment: .leading) {
                            Text("Version")
                                .font(.body)
                            Text(getAppVersion())
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                    
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                            .frame(width: 24, height: 24)
                        
                        VStack(alignment: .leading) {
                            Text("Last Updated")
                                .font(.body)
                            Text("January 17, 2025")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
                
                Section(header: Text("Contact")) {
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.blue)
                            .frame(width: 24, height: 24)
                        
                        VStack(alignment: .leading) {
                            Text("Support Email")
                                .font(.body)
                            Text("support@budgyfinance.com")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .padding(.vertical, 4)
                    .onTapGesture {
                        if let url = URL(string: "mailto:support@budgyfinance.com") {
                            UIApplication.shared.open(url)
                        }
                    }
                }
                
                Section {
                    VStack(alignment: .center, spacing: 8) {
                        Image(systemName: "checkmark.shield")
                            .font(.title)
                            .foregroundColor(.green)
                        
                        Text("Your Privacy Matters")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("We are committed to protecting your personal information and being transparent about our data practices.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                }
                .listRowBackground(Color.clear)
            }
            .navigationTitle("Legal & Privacy")
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            PrivacyPolicyView()
        }
        .sheet(isPresented: $showTermsOfService) {
            TermsOfServiceView()
        }
    }
    
    private func getAppVersion() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}

struct LegalRowView: View {
    let title: String
    let subtitle: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    LegalView()
}
