//
//  ChatUserManager.swift
//  Tinkoff Chat
//
//  Created by Даниил on 26.04.17.
//  Copyright © 2017 Даниил. All rights reserved.
//

import Foundation


//Just for history. 
class Message1 {
    
    enum MessageDataType: Int {
        case Mine = 0
        case Opponent
    }
    
    var messageText: String
    var messageTime: Date
    weak var user: User1?
    var type: MessageDataType
    
    init(_ user: User1, message: String, time: Date, type: MessageDataType = .Mine) {
        self.user = user
        self.messageText = message
        self.messageTime = time
        self.type = type
    }
    
}

class User1 {
    
    let name: String?
    let id: String
    var isOnline: Bool
    
    var mesaageHistory = [Message1]()
    
    init(name: String, id: String, isOnlineStatus: Bool) {
        self.name = name
        self.id  = id
        self.isOnline = isOnlineStatus
    }
}

extension User1: Equatable{}
func ==(lhs: User1, rhs: User1) -> Bool{
    return lhs.id == rhs.id
}


protocol UserStorageFacadeProtocol {
    func fetchUser(chatUser: User1) -> User1?
    func fetchUsers() -> [User1]
    func createFoundUser(name:String, id: String, isOnlineStatus: Bool) -> User1
    func save(user:User1)
    func changeStatusToOnline(chatUser:User1)
    func changeStatusToOffline(chatUserId:String)
    func delete(chatUser:User1)
    func sort()
}


class UserStorageFacade: UserStorageFacadeProtocol {
    
    var users = CreateUserEntity.shared.users
    
    func createFoundUser(name: String, id: String, isOnlineStatus: Bool) -> User1 {
        return User1(name: name, id: id, isOnlineStatus: isOnlineStatus)
    }
    
    func sort(){
        var applySortingByDate: Bool = false
        
        for user in users {
            if !user.mesaageHistory.isEmpty {
                applySortingByDate = true
            }
        }
        
        if applySortingByDate {
            users.sorted(by: { (first, second) -> Bool in
                (first.mesaageHistory.last?.messageTime)! < (second.mesaageHistory.last?.messageTime)!
            })
        } else {
            users.sorted(by: { (first, second) -> Bool in
                first.name! < second.name!
            })
        }
    }

    func changeStatusToOffline(chatUserId:String) {
        for user in users {
            if user.id == chatUserId {
                user.isOnline = false
                sort()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
            }
        }
        print("TEST: Changed user status \(chatUserId)")
    }
    
    func delete(chatUser: User1) {
        for user in users {
            if user.id == chatUser.id {
                //remove user
            }
        }
    }

    func changeStatusToOnline(chatUser:User1) {
        for user in users {
            if user.id == chatUser.id {
                user.isOnline = true
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
            }
        }
        print("TEST: Changed user status \(chatUser.id)")
    }

    func save(user: User1) {
        CreateUserEntity.shared.users.append(user)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
        print("TEST: User saved")
    }


    func fetchUser(chatUser: User1) -> User1? {
        if users.contains(chatUser) {
            return chatUser
        } else {
            return nil
        }
    }
    
    func fetchUsers() -> [User1] {
        print("TEST: usere in core \(CreateUserEntity.shared.users.count)")
        return users
    }
}

class CreateUserEntity {
    
    static let shared = CreateUserEntity()
    var users = [User1]()
    
}

