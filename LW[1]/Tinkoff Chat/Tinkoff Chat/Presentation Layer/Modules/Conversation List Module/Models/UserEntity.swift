//
//  UserEntity.swift
//  Tinkoff Chat
//
//  Created by Даниил on 24.03.17.
//  Copyright © 2017 Даниил. All rights reserved.
//

import Foundation
import CoreData

extension User {
    
    
    static func fethRequestsUser(id: String, in model: NSManagedObjectModel) -> NSFetchRequest<User>? {
        let templateName = "UserWithId"
        
        guard let fetchRequest = model.fetchRequestFromTemplate(withName: templateName, substitutionVariables: ["id" : id]) as? NSFetchRequest<User>
            else {
            assert(false, "No template with name \(templateName)!")
            return nil
        }
        return fetchRequest
    }
    
    static func isUserAlreadyExistInCoreData(id: String, in context: NSManagedObjectContext) -> Bool? {
        guard let model = context.persistentStoreCoordinator?.managedObjectModel else {
            assert(false)
            return nil
        }
        
        guard let fetchRequest = User.fethRequestsUser(id: id, in: model) else { return nil }
        do {
            let results = try context.fetch(fetchRequest)
            if results.first != nil {
                return true
            }
        } catch {
            print("Failed to fetch user: \(error)")
        }
        return false
    }
    
    static func findOrInsertUser(id: String, in context: NSManagedObjectContext) -> User? {
        guard let model = context.persistentStoreCoordinator?.managedObjectModel else {
            assert(false)
            return nil
        }
        
        var user: User?
        guard let fetchRequest = User.fethRequestsUser(id: id, in: model) else { return nil }
        do {
            let results = try context.fetch(fetchRequest)
            if let foundUser = results.first {
                user = foundUser
            }
        } catch {
            print("Failed to fetch user: \(error)")
        }
        
        if user == nil {
            user = User.insertUser(id: id, in: context)
            print("TEST: New user with id \(id) was added to CoreData")
        }
        return user
        
    }
    
    static func insertUser(id: String, in context: NSManagedObjectContext) -> User? {
        if let user = NSEntityDescription.insertNewObject(forEntityName: "User", into: context) as? User {
            user.id = id
            return user
        }
        return nil
    }
}


