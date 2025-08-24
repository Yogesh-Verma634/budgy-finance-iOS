import SwiftUI
import MessageUI

struct HelpSupportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showContactForm = false
    @State private var showFAQ = false
    @State private var showTutorial = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 16) {
                            Image(systemName: "questionmark.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)
                            
                            Text("Help & Support")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("We're here to help you succeed")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                        
                        // Quick Help
                        HelpSection(title: "Quick Help", icon: "lightbulb.fill", color: .yellow) {
                            VStack(spacing: 16) {
                                HelpCard(
                                    icon: "play.circle.fill",
                                    title: "App Tutorial",
                                    description: "Learn how to use BudgyFinance effectively",
                                    action: { showTutorial = true }
                                )
                                
                                HelpCard(
                                    icon: "questionmark.circle.fill",
                                    title: "Frequently Asked Questions",
                                    description: "Find answers to common questions",
                                    action: { showFAQ = true }
                                )
                                
                                HelpCard(
                                    icon: "book.fill",
                                    title: "User Guide",
                                    description: "Comprehensive guide to all features",
                                    action: { /* Open user guide */ }
                                )
                            }
                        }
                        
                        // Contact Support
                        HelpSection(title: "Contact Support", icon: "envelope.fill", color: .blue) {
                            VStack(spacing: 16) {
                                Text("Need help? Our support team is here for you")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                
                                Button(action: { showContactForm = true }) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "envelope")
                                        Text("Contact Support")
                                            .fontWeight(.medium)
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.blue)
                                    )
                                }
                                
                                VStack(spacing: 8) {
                                    Text("Response time: Usually within 24 hours")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Text("Support hours: Monday - Friday, 9 AM - 6 PM EST")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        // Common Issues
                        HelpSection(title: "Common Issues", icon: "exclamationmark.triangle.fill", color: .orange) {
                            VStack(spacing: 16) {
                                IssueCard(
                                    issue: "Receipt not processing",
                                    solution: "Ensure good lighting and clear text. Try retaking the photo."
                                )
                                
                                IssueCard(
                                    issue: "App crashes",
                                    solution: "Update to the latest version. Restart your device if needed."
                                )
                                
                                IssueCard(
                                    issue: "Data not syncing",
                                    solution: "Check your internet connection. Pull to refresh the screen."
                                )
                                
                                IssueCard(
                                    issue: "Can't log in",
                                    solution: "Verify your email and password. Use 'Forgot Password' if needed."
                                )
                            }
                        }
                        
                        // Tips & Tricks
                        HelpSection(title: "Tips & Tricks", icon: "star.fill", color: .purple) {
                            VStack(spacing: 16) {
                                TipCard(
                                    icon: "camera.fill",
                                    title: "Better Receipt Photos",
                                    description: "Hold your phone steady, ensure good lighting, and capture the entire receipt"
                                )
                                
                                TipCard(
                                    icon: "chart.bar.fill",
                                    title: "Track Spending Trends",
                                    description: "Use the Stats tab to identify spending patterns and set better budgets"
                                )
                                
                                TipCard(
                                    icon: "tag.fill",
                                    title: "Organize with Categories",
                                    description: "Create custom categories to better organize your expenses"
                                )
                                
                                TipCard(
                                    icon: "icloud.fill",
                                    title: "Regular Backups",
                                    description: "Export your data regularly to keep a backup of your financial records"
                                )
                            }
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("Help & Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showContactForm) {
            ContactSupportForm()
        }
        .sheet(isPresented: $showFAQ) {
            FAQView()
        }
        .sheet(isPresented: $showTutorial) {
            TutorialView()
        }
    }
}

// MARK: - Supporting Views
struct HelpSection<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    let content: Content
    
    init(title: String, icon: String, color: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 24)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            content
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct HelpCard: View {
    let icon: String
    let title: String
    let description: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct IssueCard: View {
    let issue: String
    let solution: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(issue)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Text(solution)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct TipCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.purple)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Placeholder Views
struct ContactSupportForm: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Contact Support Form")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("This would contain a form for users to submit support requests")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Contact Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FAQView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Frequently Asked Questions")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("This would contain common questions and answers")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding()
            .navigationTitle("FAQ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct TutorialView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("App Tutorial")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("This would contain step-by-step tutorials for app features")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Tutorial")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    HelpSupportView()
}
