//
//  AppUser.swift
//  Tinkoff Chat
//
//  Created by Даниил on 22.04.17.
//  Copyright © 2017 Даниил. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class AppUser1: NSObject {
    var userName: String = ""
    var userDescription: String = ""
    var userColor: UIColor = UIColor()
    var userImage: UIImage?
    
    var storageService = UserProfileStorageService()
    
    convenience init(name: String, description: String, color: UIColor, image: UIImage) {
        self.init()
        self.userName = name
        self.userDescription = description
        self.userColor = color
        self.userImage = image
    }
    
    override init() {
        super.init()
    }
    
    
    func saveUserViaGCD(completed: @escaping () -> (), failure: @escaping () -> ()) {
        storageService.saveUserProfileViaGCD(userToSave: self, completionHandler: {
            completed()
        }) { 
            failure()
        }
    }
    
    
    func saveUserViaOperation(completed: @escaping () -> (), failure: @escaping () -> ()) {
        storageService.saveUserProfileViaOperation(userToSave: self, completionHandler: {
            completed()
        }) {
            failure()
        }
    }
    
    func getFromFile(completed: @escaping (_ name: String, _ description: String?, _ image: Data, _ color: Data) -> ()) {
        storageService.getUserProfileFromFile { (name, description, imageData, colorData) in
            completed(name, description, imageData, colorData)
        }
    }
}


extension AppUser {
    
    static func fethRequestsAppUser(model: NSManagedObjectModel) -> NSFetchRequest<AppUser>? {
        let templateName = "AppUser"
        guard let fetchRequest = model.fetchRequestTemplate(forName: templateName) as? NSFetchRequest<AppUser> else {
            assert(false, "No template with name \(templateName)!")
            return nil
        }
        
        return fetchRequest
    }
    
    
    static func insertAppUser(in context: NSManagedObjectContext) -> AppUser? {
        if let appUser = NSEntityDescription.insertNewObject(forEntityName: "AppUser", into: context) as? AppUser {
            if appUser.currentUser == nil {
                let currentUser = User.findOrInsertUser(id: "baseID", in: context)
                appUser.currentUser = currentUser
            }
            return appUser
        }
        return nil
    }

    static func findOrInsertAppUser(in context: NSManagedObjectContext) -> AppUser? {
        guard let model = context.persistentStoreCoordinator?.managedObjectModel else {
            assert(false)
            return nil
        }
        var appUser: AppUser?
        guard let fetchRequest = AppUser.fethRequestsAppUser(model: model) else { return nil }
        do {
            let results = try context.fetch(fetchRequest)
            assert(results.count < 2, "Multiple AppUser found!")
                if let foundUser = results.first {
                    appUser = foundUser
                }
        } catch {
            print("Failed to fetch appUser: \(error)")
        }

        if appUser == nil {
            appUser = AppUser.insertAppUser(in: context)
        }
        return appUser
    }

}
