//
//  Platform.swift
//  Tinkoff Chat
//
//  Created by Даниил on 08.04.17.
//  Copyright © 2017 Даниил. All rights reserved.
//

import Foundation

struct Platform {
    
    static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0 // Use this line in Xcode 7 or newer
    }
    
}
