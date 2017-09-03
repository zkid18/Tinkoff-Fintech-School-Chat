//
//  GCDDataManager.swift
//  Tinkoff Chat
//
//  Created by Даниил on 01.04.17.
//  Copyright © 2017 Даниил. All rights reserved.
//

import Foundation
import UIKit


protocol StrorageServiceProtocol: class {
    
    func save(userName: String, userDescription: String, userImage: Data, userColor: Data, completed: @escaping () -> (), failure: @escaping () -> ())
    
    func getFile(completed: @escaping (_ userName: String, _ userDescription: String, _ userImage: Data, _ userColor: Data) -> ())
    
}

class GCDDataManager: StrorageServiceProtocol {
    
    let saveQueue = DispatchQueue.global(qos: .userInteractive)
    
    func save (userName: String, userDescription: String, userImage: Data, userColor: Data, completed: @escaping () -> (), failure: @escaping () -> ()) {
        DispatchQueue.global(qos: .userInteractive).async {
            if let plistFile = Plist(name: "userFile") {
                
                if let dict = plistFile.getMutablePlistFile() {
                    dict["userName"] = userName
                    dict["userInfo"] = userDescription
                    dict["userImage"] = userImage
                    dict["userColor"] = userColor
                    
                    do {
                        try plistFile.addValuesToPlistFile(dictionary: dict)
                        completed()
                    } catch {
                        failure()
                    }
                }
            } else {
                print("PLIST: no file")
            }
        }
    }
    

    
    func getFile(completed: @escaping (_ userName: String, _ userDescription: String, _ userImage: Data, _ userColor: Data) -> ()) {
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

    }

    func saveData() {
        
        print("old save")
    }
}
    
