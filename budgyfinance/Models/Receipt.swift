import Foundation
import SwiftUI
import FirebaseFirestore

struct Receipt: Codable, Identifiable {
    var id: String // Document ID from Firestore - made non-optional
    var storeName: String?
    var date: String? // Keep as String for compatibility with OpenAI response
    var totalAmount: Double?
    var taxAmount: Double?
    var tipAmount: Double?
    var items: [ReceiptItem]?
    var scannedTime: Date? // New property for scanned time
    var userId: String? // To link the receipt to a user
    var category: String? // New property for spending category
    var transactionDateTime: Date? // New property for actual transaction date and time
    
    // Computed property to get the parsed receipt date for sorting
    var parsedReceiptDate: Date? {
        // First try to use the new transactionDateTime field
        if let transactionDateTime = transactionDateTime {
            return transactionDateTime
        }
        
        // Fallback to parsing the date string
        guard let dateString = date else { return nil }
        
        // Try different date formats that might be used
        let dateFormatters: [DateFormatter] = [
            {
                let formatter = DateFormatter()
                formatter.dateFormat = "MM/dd/yyyy"
                return formatter
            }(),
            {
                let formatter = DateFormatter()
                formatter.dateFormat = "MM-dd-yyyy"
                return formatter
            }(),
            {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                return formatter
            }(),
            {
                let formatter = DateFormatter()
                formatter.dateFormat = "MM/dd/yy"
                return formatter
            }(),
            {
                let formatter = DateFormatter()
                formatter.dateFormat = "MM-dd-yy"
                return formatter
            }()
        ]
        
        for formatter in dateFormatters {
            if let parsedDate = formatter.date(from: dateString) {
                return parsedDate
            }
        }
        
        // If none of the formats work, return nil
        return nil
    }
    
    // Computed property to get the transaction date and time for precise sorting
    var parsedTransactionDateTime: Date? {
        // First try to use the new transactionDateTime field
        if let transactionDateTime = transactionDateTime {
            return transactionDateTime
        }
        
        // Try to parse date and time from the date string
        guard let dateString = date else { return nil }
        
        // Try different datetime formats that might include time
        let datetimeFormatters: [DateFormatter] = [
            {
                let formatter = DateFormatter()
                formatter.dateFormat = "MM/dd/yyyy HH:mm"
                return formatter
            }(),
            {
                let formatter = DateFormatter()
                formatter.dateFormat = "MM-dd-yyyy HH:mm"
                return formatter
            }(),
            {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm"
                return formatter
            }(),
            {
                let formatter = DateFormatter()
                formatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
                return formatter
            }(),
            {
                let formatter = DateFormatter()
                formatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
                return formatter
            }(),
            {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                return formatter
            }()
        ]
        
        // Try datetime formats first
        for formatter in datetimeFormatters {
            if let parsedDateTime = formatter.date(from: dateString) {
                return parsedDateTime
            }
        }
        
        // If no time found, try date-only formats and set time to 00:00
        let dateFormatters: [DateFormatter] = [
            {
                let formatter = DateFormatter()
                formatter.dateFormat = "MM/dd/yyyy"
                return formatter
            }(),
            {
                let formatter = DateFormatter()
                formatter.dateFormat = "MM-dd-yyyy"
                return formatter
            }(),
            {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                return formatter
            }(),
            {
                let formatter = DateFormatter()
                formatter.dateFormat = "MM/dd/yy"
                return formatter
            }(),
            {
                let formatter = DateFormatter()
                formatter.dateFormat = "MM-dd-yy"
                return formatter
            }()
        ]
        
        for formatter in dateFormatters {
            if let parsedDate = formatter.date(from: dateString) {
                // Set time to 00:00 (midnight) for date-only receipts
                let calendar = Calendar.current
                var components = calendar.dateComponents([.year, .month, .day], from: parsedDate)
                components.hour = 0
                components.minute = 0
                components.second = 0
                return calendar.date(from: components)
            }
        }
        
        // If none of the formats work, return nil
        return nil
    }
    
    // Custom coding keys to handle potential field mismatches
    enum CodingKeys: String, CodingKey {
        case id
        case storeName
        case date
        case totalAmount
        case taxAmount
        case tipAmount
        case items
        case scannedTime
        case userId
        case category
        case transactionDateTime
    }
    
    init(id: String = UUID().uuidString, storeName: String? = nil, date: String? = nil, totalAmount: Double? = nil, taxAmount: Double? = nil, tipAmount: Double? = nil, items: [ReceiptItem]? = nil, scannedTime: Date? = nil, userId: String? = nil, category: String? = nil, transactionDateTime: Date? = nil) {
        self.id = id
        self.storeName = storeName
        self.date = date
        self.totalAmount = totalAmount
        self.taxAmount = taxAmount
        self.tipAmount = tipAmount
        self.items = items
        self.scannedTime = scannedTime
        self.userId = userId
        self.category = category
        self.transactionDateTime = transactionDateTime
    }
    
    // Custom initializer from decoder to handle potential field mismatches
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try to decode id, but if it fails, use a default UUID
        if let id = try? container.decode(String.self, forKey: .id) {
            self.id = id
        } else {
            self.id = UUID().uuidString
        }
        
        // Decode other fields with nil coalescing for safety
        self.storeName = try? container.decodeIfPresent(String.self, forKey: .storeName)
        self.date = try? container.decodeIfPresent(String.self, forKey: .date)
        self.totalAmount = try? container.decodeIfPresent(Double.self, forKey: .totalAmount)
        self.taxAmount = try? container.decodeIfPresent(Double.self, forKey: .taxAmount)
        self.tipAmount = try? container.decodeIfPresent(Double.self, forKey: .tipAmount)
        self.items = try? container.decodeIfPresent([ReceiptItem].self, forKey: .items)
        self.userId = try? container.decodeIfPresent(String.self, forKey: .userId)
        self.category = try? container.decodeIfPresent(String.self, forKey: .category)
        
        // Handle scannedTime which could be a Timestamp or Date
        if let timestamp = try? container.decodeIfPresent(Timestamp.self, forKey: .scannedTime) {
            self.scannedTime = timestamp.dateValue()
        } else {
            self.scannedTime = try? container.decodeIfPresent(Date.self, forKey: .scannedTime)
        }
        
        // Handle transactionDateTime which could be a Timestamp or Date
        if let timestamp = try? container.decodeIfPresent(Timestamp.self, forKey: .transactionDateTime) {
            self.transactionDateTime = timestamp.dateValue()
        } else {
            self.transactionDateTime = try? container.decodeIfPresent(Date.self, forKey: .transactionDateTime)
        }
    }
    
    // Custom encode method to ensure proper encoding
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(storeName, forKey: .storeName)
        try container.encodeIfPresent(date, forKey: .date)
        try container.encodeIfPresent(totalAmount, forKey: .totalAmount)
        try container.encodeIfPresent(taxAmount, forKey: .taxAmount)
        try container.encodeIfPresent(tipAmount, forKey: .tipAmount)
        try container.encodeIfPresent(items, forKey: .items)
        try container.encodeIfPresent(userId, forKey: .userId)
        try container.encodeIfPresent(category, forKey: .category)
        
        // Encode scannedTime as Timestamp for Firestore compatibility
        if let scannedTime = scannedTime {
            try container.encode(Timestamp(date: scannedTime), forKey: .scannedTime)
        }
        
        // Encode transactionDateTime as Timestamp for Firestore compatibility
        if let transactionDateTime = transactionDateTime {
            try container.encode(Timestamp(date: transactionDateTime), forKey: .transactionDateTime)
        }
    }
}

struct ReceiptItem: Codable, Identifiable {
    var id: String
    var name: String?
    var price: Double?
    var quantity: Double?
    var category: String? // Category for individual items
    
    init(id: String = UUID().uuidString, name: String? = nil, price: Double? = nil, quantity: Double? = nil, category: String? = nil) {
        self.id = id
        self.name = name
        self.price = price
        self.quantity = quantity
        self.category = category
    }
    
    // Custom initializer from decoder to handle missing id field
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try to decode id, but if it fails, use a default UUID
        if let id = try? container.decode(String.self, forKey: .id) {
            self.id = id
        } else {
            self.id = UUID().uuidString
        }
        
        // Decode other fields
        self.name = try? container.decodeIfPresent(String.self, forKey: .name)
        self.price = try? container.decodeIfPresent(Double.self, forKey: .price)
        self.quantity = try? container.decodeIfPresent(Double.self, forKey: .quantity)
        self.category = try? container.decodeIfPresent(String.self, forKey: .category)
    }
    
    // Custom coding keys
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case price
        case quantity
        case category
    }
}

// Spending categories
enum SpendingCategory: String, CaseIterable, Codable {
    case food = "Food & Dining"
    case transportation = "Transportation"
    case shopping = "Shopping"
    case entertainment = "Entertainment"
    case utilities = "Utilities"
    case healthcare = "Healthcare"
    case education = "Education"
    case travel = "Travel"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .transportation: return "car.fill"
        case .shopping: return "bag.fill"
        case .entertainment: return "tv.fill"
        case .utilities: return "bolt.fill"
        case .healthcare: return "cross.fill"
        case .education: return "book.fill"
        case .travel: return "airplane"
        case .other: return "ellipsis.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .food: return .orange
        case .transportation: return .blue
        case .shopping: return .purple
        case .entertainment: return .pink
        case .utilities: return .yellow
        case .healthcare: return .red
        case .education: return .green
        case .travel: return .cyan
        case .other: return .gray
        }
    }
}
