import Foundation
import CoreData
import Foundation

@objc(Receipt)
public class Receipt: NSManagedObject, Identifiable {
    @NSManaged public var date: Date
    @NSManaged public var totalAmount: Double
    @NSManaged public var items: String
}

extension Receipt {
    static func fetchAll() -> NSFetchRequest<Receipt> {
        let request = NSFetchRequest<Receipt>(entityName: "Receipt")
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        return request
    }
}
