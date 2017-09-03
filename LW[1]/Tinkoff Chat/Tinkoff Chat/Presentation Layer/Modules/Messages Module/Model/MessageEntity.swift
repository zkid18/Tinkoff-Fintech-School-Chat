//
//  MessageEntity.swift
//  Tinkoff Chat
//
//  Created by Даниил on 24.03.17.
//  Copyright © 2017 Даниил. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension Message {

    static func fethRequestsUser(id: String, in context: NSManagedObjectContext) -> NSFetchRequest<Message>? {
        let templateName = "MessagesInConversation"
        guard let model = context.persistentStoreCoordinator?.managedObjectModel else {
            assert(false)
            return nil
        }
        
        guard let fetchRequest = model.fetchRequestFromTemplate(withName: templateName, substitutionVariables: ["id" : id]) as? NSFetchRequest<Message>
            else {
                assert(false, "No template with name \(templateName)!")
                return nil
        }
        return fetchRequest
    }
    
    static func insertMessage(id: String, in context: NSManagedObjectContext) -> Message? {
        if let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as? Message {
            message.messageId = id
            return message
        }
        return nil
    }

}
