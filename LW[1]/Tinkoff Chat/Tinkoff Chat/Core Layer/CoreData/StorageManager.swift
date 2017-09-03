//
//  StorageManager.swift
//  Tinkoff Chat
//
//  Created by Даниил on 29.04.17.
//  Copyright © 2017 Даниил. All rights reserved.
//

import Foundation
import CoreData
import UIKit

protocol IStorageManager {
    func saveContext()
    func saveNewConversationWithUser(userID: String, userName: String, status: Bool, completed: @escaping () -> (), failure: @escaping () -> ())
}

class StorageManager: NSObject {
    
    var coreDataStack = (UIApplication.shared.delegate as! AppDelegate).coreDataStack
    
    public func save(name: String, description: String, imageData: NSData, completed: @escaping () -> (), failure: @escaping () -> ()) {
        
        let mainContext = coreDataStack.mainContext
        let appUser = AppUser.findOrInsertAppUser(in: mainContext!)
        appUser?.currentUser?.name = name
        appUser?.currentUser?.descriptionUser = description
        appUser?.currentUser?.image = imageData
        appUser?.currentUser?.isOnline = true
        
        coreDataStack.performSave(context: mainContext!, completionHandler: {
            completed()
            print("TEST: saved successfly to CoreData")
        }, failureHandler: {
            failure()
        })
    }
    
    public func fetchAppUser() -> AppUser {
        let mainContext = coreDataStack.mainContext
        return AppUser.findOrInsertAppUser(in: mainContext!)!
    }
    
    
    public func saveNewConversationWithUser(userID: String, userName: String, status: Bool, completed: @escaping () -> (), failure: @escaping () -> ()) {
        
        let mainContext = coreDataStack.mainContext
        //let saveContext = coreDataStack.saveContext
        
        let appUser = AppUser.findOrInsertAppUser(in: mainContext!)
        
        let isUserAlreadyExist = User.isUserAlreadyExistInCoreData(id: userID, in: mainContext!)
        
        print("TEST: isUserExist in Core Data: \(String(describing: isUserAlreadyExist))")
        if let isUserAlreadyExist = isUserAlreadyExist {
            
            if !isUserAlreadyExist {
                
                let newUser = User.findOrInsertUser(id: userID, in: mainContext!)
                let newConversation = Conversation.findOrInsertConversation(id: generateID(), in: mainContext!)
                
                print("Conversation: \((newConversation?.id)!)")
                
                newUser?.name = userName
                newUser?.isOnline = true
                newUser?.id = userID
                
                newConversation?.participant = newUser
                newConversation?.isOnline = true
                
                appUser?.users?.adding(newUser!)
                appUser?.convestations?.adding(newConversation!)
                
                coreDataStack.performSave(context: mainContext!, completionHandler: {
                    completed()
                    print("TEST: saved user successfly to CoreData")
                }, failureHandler: {
                    failure()
                })
            }
            
            //Change status to online
            if isUserAlreadyExist {
                let currentUser = User.findOrInsertUser(id: userID, in: mainContext!)
                print("Storage offline: \(String(describing: currentUser?.name))")
                
                currentUser?.isOnline = true
                currentUser?.usersConversation?.isOnline = true
 
                coreDataStack.performSave(context: mainContext!, completionHandler: {
                    completed()
                    print("TEST: online user was changed successfully")
                }, failureHandler: {
                    failure()
                })
            }
        }
    }
    
    public func changeStatusToOffline(userID:String, completed: @escaping () -> (), failure: @escaping () -> ()) {
        
        let mainContext = coreDataStack.mainContext
        
        let isUserAlreadyExist = User.isUserAlreadyExistInCoreData(id: userID, in: mainContext!)
        
        if let isUserAlredyExist = isUserAlreadyExist {
            if isUserAlredyExist {
                let currentUser = User.findOrInsertUser(id: userID, in: mainContext!)
                
                print("Storage offline: \(String(describing: currentUser?.name))")
                currentUser?.isOnline = false
                currentUser?.usersConversation?.isOnline = false
                
                coreDataStack.performSave(context: mainContext!, completionHandler: {
                    completed()
                    print("TEST: offline user was changed successfullt")
                }, failureHandler: {
                    failure()
                })
            }
        }
    }
    
    public func saveNewMessageFromAppUserInConversation(conversationID: String, text: String, date: Date, userID: String, completed: @escaping () -> (), failure: @escaping () -> ()) {
        
        let mainContext = coreDataStack.mainContext
        let appUser = AppUser.findOrInsertAppUser(in: mainContext!)
        
        print("Conversation: \(conversationID)")
        print("Conversation existed converstaion \(String(describing: Conversation.isConversationAlreadyExistInCoreData(id: conversationID, in: mainContext!)))")
        
        let currentConversation = Conversation.findOrInsertConversation(id: conversationID, in: mainContext!)
        let currentUser = currentConversation?.participant
        
        print("TEST conversatio \(String(describing: currentConversation?.id))")
        
        let time = String(date.timeIntervalSince1970)
        
        let currentMessage = Message.insertMessage(id: generateID(), in: mainContext!)
        
        currentMessage?.text = text
        currentMessage?.time = time
        currentMessage?.sender = appUser?.currentUser
        currentMessage?.reciever = currentUser
        currentMessage?.conversation = currentConversation
        currentMessage?.lastMessageInConversation = currentConversation
        
        appUser?.lastMessage = currentMessage
        
        coreDataStack.performSave(context: mainContext!, completionHandler: {
            completed()
            print("TEST: message was saved to CoreData successfully")
        }, failureHandler: {
            failure()
        })
    }
    
    public func saveRecievedMessage(fromUserWithID: String, toUserWithID: String, text: String, completed: @escaping () -> (), failure: @escaping () -> ()) {
        
        let mainContext = coreDataStack.mainContext
        let appUser = AppUser.findOrInsertAppUser(in: mainContext!)
        
        let currentUser = User.findOrInsertUser(id: fromUserWithID, in: mainContext!)
        let currentConversation = currentUser?.usersConversation
        
        print("TEST conversatio \(String(describing: currentConversation?.id))")
        
        let currentMessage = Message.insertMessage(id: generateID(), in: mainContext!)
        let time = String(Date().timeIntervalSince1970)
        
        currentMessage?.text = text
        currentMessage?.time = time
        currentMessage?.sender = currentUser
        currentMessage?.reciever = appUser?.currentUser
        currentMessage?.conversation = currentConversation
        currentMessage?.lastMessageInConversation = currentConversation
        
        coreDataStack.performSave(context: mainContext!, completionHandler: {
            completed()
            print("TEST: recievd message was saved to CoreData successfully")
        }, failureHandler: {
            failure()
        })
    }
    
    public func changeConversationStatusWhenBackgroundMode() {
        
        let mainContext = coreDataStack.mainContext
        
        let retrievedConversations = Conversation.findOnlineConversations(in: mainContext!)
        
        if let conversations = retrievedConversations {
            for conversation in conversations {
                conversation.isOnline = false
            }
        }
        
        coreDataStack.performSave(context: mainContext!, completionHandler: {
            print("TEST: conversation changed to offline")
        }, failureHandler: {
        })
        
    }
    
    
    private func generateID()-> String {
        
        var timeStamp: String {
            return "\(arc4random())" + "\(Date().timeIntervalSince1970)" + "\(arc4random())"
        }
        return String(timeStamp.hashValue)
    }
}
