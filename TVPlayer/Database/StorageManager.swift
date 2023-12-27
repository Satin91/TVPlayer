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
    
    func create(object: TVChannelCore)
    func fetchAll<T:NSFetchRequestResult>() -> [T]
    func delete<T:NSFetchRequestResult>(object: T.Type, predicate: NSPredicate)
}

public final class StorageManager: NSObject {
    private var appDelegate: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }
    
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
    
    var entityName = ""
    
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

    func deleteAll() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        do {
            let objects = try context.fetch(fetchRequest) as? [NSManagedObject]
            objects?.forEach { context.delete($0) }
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension StorageManager: StorageManagerProtocol {
    
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
     
    func delete<T:NSFetchRequestResult>(object: T.Type, predicate: NSPredicate) {
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
