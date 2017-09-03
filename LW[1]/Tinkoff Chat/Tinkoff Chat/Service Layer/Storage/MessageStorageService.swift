//
//  MessageStorageService.swift
//  Tinkoff Chat
//
//  Created by Даниил on 08.05.17.
//  Copyright © 2017 Даниил. All rights reserved.
//

import Foundation

protocol IMessageStorageService {
    func saveMessageToConversation(in conversationWithID: String, messageText: String, messageDate: Date, userID: String)
}


class MessageStorageService: IMessageStorageService {
    let storageManager = StorageManager()
    
    func saveMessageToConversation(in conversationWithID: String, messageText: String, messageDate: Date, userID: String) {
        
        storageManager.saveNewMessageFromAppUserInConversation(conversationID: conversationWithID, text: messageText, date: messageDate, userID: userID, completed: {
            print("Perform save to coreData")
        }) { 
            print("Failed save to CoreData")
        }
    }
    
}
