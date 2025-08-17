import Foundation
import FirebaseFirestore
import FirebaseAuth

class BudgetManager: ObservableObject {
    static let shared = BudgetManager()
    @Published var monthlyBudget: Double = 0.0
    @Published var currentMonthSpent: Double = 0.0
    @Published var isLoading = false
    
    private let db = Firestore.firestore()
    
    func setMonthlyBudget(_ amount: Double, completion: @escaping (Error?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "BudgetManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        let budgetData: [String: Any] = [
            "monthlyBudget": amount,
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        db.collection("users").document(userId).collection("settings").document("budget").setData(budgetData) { error in
            DispatchQueue.main.async {
                if error == nil {
                    self.monthlyBudget = amount
                }
                completion(error)
            }
        }
    }
    
    func fetchMonthlyBudget(completion: @escaping (Error?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("BudgetManager: No user logged in")
            DispatchQueue.main.async {
                self.isLoading = false
            }
            completion(NSError(domain: "BudgetManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        print("BudgetManager: Fetching budget for user: \(userId)")
        isLoading = true
        
        db.collection("users").document(userId).collection("settings").document("budget").getDocument { document, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    print("BudgetManager: Error fetching budget: \(error.localizedDescription)")
                    completion(error)
                    return
                }
                
                if let document = document, document.exists {
                    self.monthlyBudget = document.data()?["monthlyBudget"] as? Double ?? 0.0
                    print("BudgetManager: Successfully fetched budget: $\(self.monthlyBudget)")
                } else {
                    print("BudgetManager: No budget document found, setting to 0")
                    self.monthlyBudget = 0.0
                }
                
                completion(nil)
            }
        }
    }
    
    func calculateCurrentMonthSpent(receipts: [Receipt]) -> Double {
        let currentMonth = Calendar.current.component(.month, from: Date())
        let currentYear = Calendar.current.component(.year, from: Date())
        
        return receipts.filter { receipt in
            // Use actual receipt date for budget calculation, not when it was scanned
            let receiptDate = receipt.parsedTransactionDateTime ?? receipt.parsedReceiptDate ?? receipt.scannedTime
            guard let date = receiptDate else { return false }
            let receiptMonth = Calendar.current.component(.month, from: date)
            let receiptYear = Calendar.current.component(.year, from: date)
            return receiptMonth == currentMonth && receiptYear == currentYear
        }
        .reduce(0) { $0 + ($1.totalAmount ?? 0) }
    }
    
    func getRemainingBudget() -> Double {
        return max(0, monthlyBudget - currentMonthSpent)
    }
    
    func getBudgetProgress() -> Double {
        guard monthlyBudget > 0 else { return 0 }
        return min(1.0, currentMonthSpent / monthlyBudget)
    }
    
    func getBudgetStatus() -> BudgetStatus {
        let progress = getBudgetProgress()
        let remaining = getRemainingBudget()
        
        if progress >= 0.9 {
            return .critical
        } else if progress >= 0.7 {
            return .warning
        } else {
            return .good
        }
    }
}

enum BudgetStatus {
    case good
    case warning
    case critical
    
    var color: String {
        switch self {
        case .good: return "green"
        case .warning: return "orange"
        case .critical: return "red"
        }
    }
    
    var message: String {
        switch self {
        case .good: return "You're on track with your budget!"
        case .warning: return "You're approaching your budget limit."
        case .critical: return "You've nearly reached your budget limit!"
        }
    }
} 