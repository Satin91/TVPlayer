//
//  DatabaseManager.swift
//  TVPlayer
//
//  Created by Артур Кулик on 27.12.2023.
//

import UIKit
import CoreData


protocol StorageManagerProtocol {
    var context: NSManagedObjectContext { get }
    
    func isExists<T: NSFetchRequestResult>(object: T.Type, with predicate: NSPredicate) -> Bool
    func create(object: TVChannelCore)
    func fetchAll<T:NSFetchRequestResult>() -> [T]
    func delete<T:NSFetchRequestResult>(object: T.Type, with predicate: NSPredicate)
}

public final class StorageManager: NSObject {
    
    var entityName = ""
    
    private let container: NSPersistentContainer = {
       let container = NSPersistentContainer(name: "TVChannelCoreDataModel")
        container.loadPersistentStores { description, error in
            if let error {
                fatalError(error.localizedDescription)
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    convenience init(entityName: String) {
        self.init()
        self.entityName = entityName
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error save context in core data:: \(error.localizedDescription)")
            }
        }
    }
}

extension StorageManager: StorageManagerProtocol {
    
    func isExists<T: NSFetchRequestResult>(object: T.Type, with predicate: NSPredicate) -> Bool {
        let fetchRequest = NSFetchRequest<T>(entityName: entityName)
        fetchRequest.predicate = predicate
        do {
            let objects = try context.fetch(fetchRequest)
            return !objects.isEmpty
        } catch {
            print(error)
            return false
        }
    }
    
    func create<T: NSManagedObject>(object: T) {
        saveContext()
    }
    
    func fetchAll<T:NSFetchRequestResult>() -> [T] {
        let fetchRequest = NSFetchRequest<T>(entityName: entityName)
        do {
            let models = try context.fetch(fetchRequest)
            return models
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
     
    func delete<T:NSFetchRequestResult>(object: T.Type, with predicate: NSPredicate) {
        let fetchRequest = NSFetchRequest<T>(entityName: entityName)
        fetchRequest.predicate = predicate
        do {
            let objects = try context.fetch(fetchRequest)
            guard let object = objects.first as? NSManagedObject else {
                print("ERROR: OBJECT NOT FOND")
                return
            }
            context.delete(object)
            saveContext()
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
}
