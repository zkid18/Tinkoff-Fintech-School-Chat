//
//  UserProfileStorage.swift
//  Tinkoff Chat
//
//  Created by Даниил on 22.04.17.
//  Copyright © 2017 Даниил. All rights reserved.
//

import Foundation
import UIKit

protocol IUserProfileStorageService {
    
    func saveUserProfileViaGCD(userToSave: AppUser1, completionHandler: @escaping () -> (), failure: @escaping () -> ())
    
    func saveUserProfileViaOperation(userToSave: AppUser1, completionHandler: @escaping () -> (), failure: @escaping () -> ())
    
    func saveUserProfileViaCoreData(text: String, description: String, image: UIImage, completionHandler: @escaping () -> (), failure: @escaping () -> ())
    
    func getUserProfileFromFile(completed: @escaping (_ userName: String, _ userDescription: String, _ userImage: Data, _ userColor: Data) -> ())
    
    func getUserProfileViaCoreData(completed: @escaping (_ userName: String?, _ userDescription: String?, _ userImage: NSData?) -> ())
}

class UserProfileStorageService: IUserProfileStorageService {
    
    let GCDManager = GCDDataManager()
    let OperationManager = OperationDataManager()
    let storageManager = StorageManager()
    
    func getUserProfileFromFile(completed: @escaping (String, String, Data, Data) -> ()) {
        
        DispatchQueue.main.async {
            if let plist = Plist(name: "userFile") {
                if let dict = plist.getValuesInPlistFile() {
                    completed((dict["userName"] as? String)!,
                              (dict["userInfo"] as? String)!,
                              (dict["userImage"] as? Data)!,
                              (dict["userColor"] as? Data)!)
                }
            }
        }

//
//        GCDManager.getFile {
//            (userName, userDescription, userImage, userColor) in
//            completed(userName, userDescription, userImage, userColor)
//        }
    }

    func saveUserProfileViaGCD(userToSave: AppUser1, completionHandler: @escaping () -> (), failure: @escaping () -> ()) {
        
        GCDManager.save (userName: userToSave.userName,
                             userDescription: userToSave.userDescription,
                             userImage: UIImagePNGRepresentation(userToSave.userImage!)!,
                             userColor: NSKeyedArchiver.archivedData(withRootObject: userToSave.userColor),
                             
            completed: {
                completionHandler()
            },
            failure: {
                failure()
            })
    }
    
    
    func saveUserProfileViaOperation(userToSave: AppUser1, completionHandler: @escaping () -> (), failure: @escaping () -> ()) {
        
         print("Operation: saving")
        
        OperationManager.user = userToSave
        OperationManager.start()
        
        if OperationManager.isFinished == false {
            completionHandler()
            //print("Operation: finished")
        } else {
            failure()
            //print("Operation: not finished")
        }
    }
    
    
    func saveUserProfileViaCoreData(text: String, description: String, image: UIImage, completionHandler: @escaping () -> (), failure: @escaping () -> ()) {
        storageManager.save(name: text,
                            description: description,
                            imageData: UIImagePNGRepresentation(image)! as NSData,
                    completed: {
                        completionHandler()
                    }, failure: failure )
    }

    
    func getUserProfileViaCoreData(completed: @escaping (String?, String?, NSData?) -> ()) {
        if  let currentUser = storageManager.fetchAppUser().currentUser {
            completed (currentUser.name, currentUser.descriptionUser, currentUser.image)
        }
    }

}
