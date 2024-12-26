//
//  CoreDataManager.swift
//  budgyfinance
//
//  Created by Yogesh Verma on 25/12/24.
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()

    let container: NSPersistentContainer

    private init() {
        container = NSPersistentContainer(name: "BudgyFinanceModel")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
            else {
                print("Core Data stack loaded successfully: \(description)")
            }
        }
    }

    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    fatalError("Failed to save Core Data context: \(error)")
                }
            }
        }
}
