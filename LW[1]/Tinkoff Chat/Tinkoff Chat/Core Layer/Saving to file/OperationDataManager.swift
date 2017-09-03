//
//  OperationDataManager.swift
//  Tinkoff Chat
//
//  Created by Даниил on 01.04.17.
//  Copyright © 2017 Даниил. All rights reserved.
//

import Foundation
import UIKit


class SaveOperation: Operation {
    
    var user: AppUser1?
    
    override func start()
    {
        if let plist = Plist(name: "userFile") {
            if let dict = plist.getMutablePlistFile()  {
                
                if let name = self.user?.userName {
                    dict["userName"] = name
                    do {
                        try plist.addValuesToPlistFile(dictionary: dict)
                    } catch {
                        print(error)
                    }
                }
                
                if let description = self.user?.userDescription {
                    
                    dict["userInfo"] = description
                    do {
                        try plist.addValuesToPlistFile(dictionary: dict)
                    } catch {
                        print(error)
                    }
                }
                
                if let color = self.user?.userColor{
                    
                    let colorData = NSKeyedArchiver.archivedData(withRootObject: color)
                    dict["userColor"] = colorData
                    do {
                        try plist.addValuesToPlistFile(dictionary: dict)
                    } catch {
                        print(error)
                    }
                }
                
                if let image = self.user?.userImage{
                    let imageData = UIImagePNGRepresentation(image)!
                    dict["userImage"] = imageData
                    do {
                        try plist.addValuesToPlistFile(dictionary: dict)
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
}

class OperationDataManager: Operation {
 
    var user: AppUser1?
    override func start() {
        if let plist = Plist(name: "userFile") {
            if let dict = plist.getMutablePlistFile() {
                dict["userName"] = user?.userName
                dict["userInfo"] = user?.userDescription
                dict["userColor"] = NSKeyedArchiver.archivedData(withRootObject: user?.userColor as Any)
                dict["userImage"] = UIImagePNGRepresentation((user?.userImage)!)
                do {
                    try plist.addValuesToPlistFile(dictionary: dict)
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func checkSaving() {
        if isFinished == true {
            print("Operation: finished")
        } else {
            print("Operation: not finished")
        }
    }
    
}

