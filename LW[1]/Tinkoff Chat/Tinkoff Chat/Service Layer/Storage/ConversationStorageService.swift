//
//  ConversationStorageService.swift
//  Tinkoff Chat
//
//  Created by Даниил on 19.05.17.
//  Copyright © 2017 Даниил. All rights reserved.
//

import Foundation

protocol IConversationStorageService {
    func changeConversationIsOnlineStatus()
}


class ConversationStorageService: IConversationStorageService {
    
    let storageManager = StorageManager()
    
    func changeConversationIsOnlineStatus() {
        storageManager.changeConversationStatusWhenBackgroundMode()
    }
    
}
