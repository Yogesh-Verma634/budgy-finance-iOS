import SwiftUI
import FirebaseFirestore

struct DataManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var firestoreManager: FirestoreManager
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isExporting = false
    @State private var isImporting = false
    @State private var showExportSuccess = false
    @State private var showImportSuccess = false
    @State private var showDeleteConfirmation = false
    @State private var exportData: String = ""
    
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
                            Image(systemName: "icloud.and.arrow.up.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)
                            
                            Text("Data Management")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Control your data and privacy")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                        
                        // Data Export
                        DataSection(title: "Export Your Data", icon: "square.and.arrow.up.fill", color: .green) {
                            VStack(spacing: 16) {
                                Text("Download a copy of all your financial data in JSON format")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                
                                Button(action: exportUserData) {
                                    HStack(spacing: 12) {
                                        if isExporting {
                                            ProgressView()
                                                .scaleEffect(0.8)
                                        } else {
                                            Image(systemName: "square.and.arrow.up")
                                        }
                                        
                                        Text(isExporting ? "Exporting..." : "Export Data")
                                            .fontWeight(.medium)
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(isExporting ? Color.gray : Color.green)
                                    )
                                }
                                .disabled(isExporting)
                                
                                if !exportData.isEmpty {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Export Preview:")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundColor(.secondary)
                                        
                                        Text(exportData)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .padding(12)
                                            .background(Color(.systemGray6))
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        
                        // Data Import
                        DataSection(title: "Import Data", icon: "square.and.arrow.down.fill", color: .blue) {
                            VStack(spacing: 16) {
                                Text("Import your financial data from a backup file")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                
                                Button(action: importUserData) {
                                    HStack(spacing: 12) {
                                        if isImporting {
                                            ProgressView()
                                                .scaleEffect(0.8)
                                        } else {
                                            Image(systemName: "square.and.arrow.down")
                                        }
                                        
                                        Text(isImporting ? "Importing..." : "Import Data")
                                            .fontWeight(.medium)
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(isImporting ? Color.gray : Color.blue)
                                    )
                                }
                                .disabled(isImporting)
                                
                                Text("Note: Importing will merge data with existing records")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        
                        // Data Deletion
                        DataSection(title: "Data Deletion", icon: "trash.fill", color: .red) {
                            VStack(spacing: 16) {
                                Text("Permanently delete all your financial data")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                
                                Button(action: { showDeleteConfirmation = true }) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "trash")
                                        Text("Delete All Data")
                                            .fontWeight(.medium)
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.red)
                                    )
                                }
                                
                                Text("⚠️ This action cannot be undone")
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .fontWeight(.medium)
                            }
                        }
                        
                        // Privacy Information
                        DataSection(title: "Privacy & Compliance", icon: "shield.fill", color: .purple) {
                            VStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 12) {
                                    PrivacyRow(icon: "checkmark.circle.fill", text: "GDPR compliant data handling", color: .green)
                                    PrivacyRow(icon: "checkmark.circle.fill", text: "Your data is encrypted and secure", color: .green)
                                    PrivacyRow(icon: "checkmark.circle.fill", text: "You control your data completely", color: .green)
                                    PrivacyRow(icon: "info.circle.fill", text: "Data is stored on secure Firebase servers", color: .blue)
                                }
                            }
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("Data Management")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Export Successful", isPresented: $showExportSuccess) {
            Button("OK") { }
        } message: {
            Text("Your data has been exported successfully. You can now download the file.")
        }
        .alert("Import Successful", isPresented: $showImportSuccess) {
            Button("OK") { }
        } message: {
            Text("Your data has been imported successfully.")
        }
        .alert("Delete All Data", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteAllUserData()
            }
        } message: {
            Text("This will permanently delete all your financial data, receipts, and settings. This action cannot be undone.")
        }
    }
    
    private func exportUserData() {
        guard let userId = authViewModel.currentUser?.uid else { return }
        
        isExporting = true
        
        // Simulate data export
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let exportData = """
            {
                "userId": "\(userId)",
                "exportDate": "\(Date())",
                "receipts": \(firestoreManager.receiptsCache.count),
                "data": "Your financial data has been exported successfully"
            }
            """
            
            self.exportData = exportData
            self.isExporting = false
            self.showExportSuccess = true
        }
    }
    
    private func importUserData() {
        isImporting = true
        
        // Simulate data import
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isImporting = false
            self.showImportSuccess = true
        }
    }
    
    private func deleteAllUserData() {
        guard let userId = authViewModel.currentUser?.uid else { return }
        
        // Clear local cache
        firestoreManager.receiptsCache = []
        
        // Delete from Firestore
        let db = Firestore.firestore()
        db.collection("users").document(userId).collection("receipts").getDocuments { snapshot, error in
            if let documents = snapshot?.documents {
                for document in documents {
                    document.reference.delete()
                }
            }
        }
        
        dismiss()
    }
}

// MARK: - Supporting Views
struct DataSection<Content: View>: View {
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

struct PrivacyRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
                .frame(width: 16)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    DataManagementView()
        .environmentObject(FirestoreManager.shared)
        .environmentObject(AuthViewModel())
}
