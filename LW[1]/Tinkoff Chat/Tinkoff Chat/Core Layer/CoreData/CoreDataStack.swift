//
//  StorageManager.swift
//  Tinkoff Chat
//
//  Created by Даниил on 28.04.17.
//  Copyright © 2017 Даниил. All rights reserved.
//

import Foundation
import CoreData

protocol CoreDataStackDelegate {
    func getContext() -> NSManagedObjectContext
}

class CoreDataStack {
    
    private var storeURL: URL {
        get {
            let documentDirURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let url = documentDirURL.appendingPathComponent("Store.sqlite")
            return url
        }
    }

    //MARK: - NSManagedObjectModel
    private let managedObjectModelName = "Storage"
    private var _managedObjectModel: NSManagedObjectModel?
    private var managedObjectModel: NSManagedObjectModel? {
        get {
            if _managedObjectModel == nil {
                guard let modelURL = Bundle.main.url(forResource: managedObjectModelName, withExtension: "momd") else {
                    print("Empty model url!")
                    return nil
                }
                _managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)
            }
            return _managedObjectModel
        }
    }

    //MARK: - NSPersistentStoreCoordinator
    private var _presistentStoreCoordinator: NSPersistentStoreCoordinator?
    private var presistentStoreCoordinator: NSPersistentStoreCoordinator? {
        get {
            if _presistentStoreCoordinator == nil {
                guard let model = self.managedObjectModel else {
                    print("Empty managed object model!")
                    return nil
                }
                _presistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
                
                do {
                    try _presistentStoreCoordinator?.addPersistentStore(ofType: NSSQLiteStoreType,
                                                                        configurationName: nil,
                                                                        at: storeURL,
                                                                        options: nil)
                } catch {
                    assert(false, "Error adding persistent store to coordinator: \(error)")
                }
            }
            return _presistentStoreCoordinator
        }
    }
        
    //MARK: - NSMamagedObjectContext (Master)
    private var _masterContext: NSManagedObjectContext?
    private var masterContext: NSManagedObjectContext? {
            get {
                if _masterContext == nil {
                    let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                    guard let persistentStoreCoordinator = self.presistentStoreCoordinator else {
                        print("Empty persistent store coordinator!")
                        return nil
                    }
                    context.persistentStoreCoordinator = persistentStoreCoordinator
                    context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
                    context.undoManager = nil
                    _masterContext = context
                }
                return _masterContext
            }
        }
      
    //MARK: - NSMamagedObjectContext (Main)
    private var _mainContext: NSManagedObjectContext?
    public var mainContext: NSManagedObjectContext? {
            get {
                if _mainContext == nil {
                    let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
                    guard let parentContext = self.masterContext else {
                        print("No master context!")
                        return nil
                    }
                    context.parent = parentContext
                    context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
                    context.undoManager = nil
                    _mainContext = context
                }
                return _mainContext
            }
        }

    //MARK: - NSMamagedObjectContext (Save)
    private var _saveContext: NSManagedObjectContext?
    public var saveContext: NSManagedObjectContext? {
            get {
                if _saveContext == nil {
                    let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                    guard let parentContext = self.mainContext else {
                        print("No main context!")
                        return nil
                    }
                    context.parent = parentContext
                    context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                    context.undoManager = nil
                    _saveContext = context
                }
                return _saveContext
            }
        }
        
    //MARK: - Save Context
    public func performSave(context: NSManagedObjectContext, completionHandler: (() -> Void)?, failureHandler: (() -> Void)?) {
        if context.hasChanges {
            context.perform { [weak self] in
                do {
                    try context.save()
                } catch {
                    print("Context save error: \(error)")
                    failureHandler?()
                }
                if let parent = context.parent {
                    self?.performSave(context: parent, completionHandler: completionHandler, failureHandler: failureHandler)
                } else {
                    completionHandler?()
                }
            }
        } else {
            completionHandler?()
        }
    }
}
