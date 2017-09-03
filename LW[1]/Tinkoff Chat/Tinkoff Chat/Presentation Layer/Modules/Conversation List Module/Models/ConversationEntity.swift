//
//  ConversationEntity.swift
//  Tinkoff Chat
//
//  Created by Даниил on 24.05.17.
//  Copyright © 2017 Даниил. All rights reserved.
//

import Foundation
import CoreData

extension Conversation {
    
    static func fethRequestsConversation(id: String, in model: NSManagedObjectModel) -> NSFetchRequest<Conversation>? {
        let templateName = "ConversationWithId"
        
        guard let fetchRequest = model.fetchRequestFromTemplate(withName: templateName, substitutionVariables: ["id" : id]) as? NSFetchRequest<Conversation> else {
            assert(false, "No template with name \(templateName)!")
            return nil
        }
        return fetchRequest
    }
    
    static func fetchAllOnlineConversation(in model: NSManagedObjectModel) -> NSFetchRequest<Conversation>? {
        
        let templateName = "ConversationIsOnline"
        
        guard let fetchRequest = model.fetchRequestTemplate(forName: templateName) as? NSFetchRequest<Conversation> else {
            assert(false, "No template with name \(templateName)!")
            return nil
        }
        return fetchRequest
        
    }
    
    static func isConversationAlreadyExistInCoreData(id: String, in context: NSManagedObjectContext) -> Bool? {
        guard let model = context.persistentStoreCoordinator?.managedObjectModel else {
            assert(false)
            return nil
        }
        
        guard let fetchRequest = Conversation.fethRequestsConversation(id: id, in: model) else { return nil }
        do {
            let results = try context.fetch(fetchRequest)
            if results.first != nil {
                return true
            }
        } catch {
            print("Failed to fetch conversation: \(error)")
        }
        return false
    }
    
    
    static func findOrInsertConversation(id: String, in context: NSManagedObjectContext) -> Conversation? {
        guard let model = context.persistentStoreCoordinator?.managedObjectModel else {
            assert(false)
            return nil
        }
        
        var conversation: Conversation?
        guard let fetchRequest = Conversation.fethRequestsConversation(id: id, in: model) else { return nil }
        do {
            let results = try context.fetch(fetchRequest)
            if let foundConversation = results.first {
                conversation = foundConversation
            }
        } catch {
            print("Failed to fetch conversations: \(error)")
        }
        
        if conversation == nil {
            conversation = Conversation.insertConversation(id: id, in: context)
        }
        return conversation
    }
    
    static func findOnlineConversations(in context: NSManagedObjectContext) -> [Conversation]? {
        
        guard let model = context.persistentStoreCoordinator?.managedObjectModel else {
            assert(false)
            return nil
        }
        
        var conversationArray: [Conversation] = ([])
        
        guard let fetchRequest = Conversation.fetchAllOnlineConversation(in: model) else { return nil }
        
        do {
            let results = try context.fetch(fetchRequest)
            if !results.isEmpty {conversationArray = results}
            else {return nil}
        } catch {
            print("Failed to fetch conversations: \(error)")
        }
        
        return conversationArray
        
    }
    
    static func insertConversation(id: String, in context: NSManagedObjectContext) -> Conversation? {
        if let conversation = NSEntityDescription.insertNewObject(forEntityName: "Conversation", into: context) as? Conversation {
            conversation.id = id
            return conversation
        }
        return nil
    }
    
}
