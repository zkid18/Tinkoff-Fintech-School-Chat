//
//  CommunicationManager.swift
//  Tinkoff Chat
//
//  Created by Даниил on 09.04.17.
//  Copyright © 2017 Даниил. All rights reserved.
//

import UIKit

protocol ContactManagerDelegate: class {
    func becomeOnline()
    func becomeOffline()
}

protocol CommunicatorDelegate : class {
    
    func didFoundUser(userID: String, userName: String?)
    func didLostUser(userID: String)
    func failedToStartBrowsingForUsers(error: Error)
    func failedToStartAdvertising(error: Error)
    func didRecieveMessage(text: String, fromUser: String, toUser: String)
    
}

protocol SendMessageProtocol: class {
    func sendMessage(messageText: String, userID: String)
}

class CommunicationManager: NSObject, CommunicatorDelegate, SendMessageProtocol {
    
    weak var activeContactDelegate: ContactManagerDelegate?

    let userStorageFacade = UserStorageFacade()
    let storageManager = StorageManager()
    let communicator = MultipeerCommunicator()
    let messageStorage = MessageStorageService()
    
    override init() {
        super.init()
        communicator.delegate = self
    }
    
    func sendMessage(messageText: String, userID: String) {
        communicator.sendMessage(string: messageText, to: userID) { (isSent, error) in
            print("Message set")
        }
    }
    
    func didFoundUser(userID: String, userName: String?) {
        
        storageManager.saveNewConversationWithUser(userID: userID, userName: userName!, status: true, completed: {
            print("TEST: Prepare for save user with \(userID)")
            self.activeContactDelegate?.becomeOnline()
        }, failure: {
            print("Saved unsucessfully user with \(userID)")
        })
    }
    
    func didLostUser(userID: String) {
        
        storageManager.changeStatusToOffline(userID: userID, completed: {
            print("TEST: changed isOnline status of  \(userID)")
            self.activeContactDelegate?.becomeOffline()
        }) { 
            print("TEST: attempt to change isOnline failed \(userID)")
        }
    }
    
    func failedToStartAdvertising(error: Error) {
        print(error)
    }
    
    func failedToStartBrowsingForUsers(error: Error) {
        print(error)
    }
    
    func didRecieveMessage(text: String, fromUser: String, toUser: String) {
        
        storageManager.saveRecievedMessage(fromUserWithID: fromUser, toUserWithID: toUser, text: text, completed: {
            print("Saved recieved message")
        }, failure: {
            print("Recived message didin't saved")
        })
        
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "recieveMessage"), object: nil, userInfo: ["user": fromUser, "text": text])
        print("Recieved: \(text)")
    }
}
