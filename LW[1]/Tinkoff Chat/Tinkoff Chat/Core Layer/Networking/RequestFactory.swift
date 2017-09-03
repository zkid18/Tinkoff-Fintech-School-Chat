//
//  RequestFactory.swift
//  class_project
//
//  Created by Даниил on 08.05.17.
//  Copyright © 2017 Даниил. All rights reserved.
//

import Foundation

struct RequstFactory {
    
    struct PhotosRequests {
        
        static func photosConfig() -> RequestConfig<[PhotoApiModel]> {
            let apiKey = Bundle.main.object(forInfoDictionaryKey: "apiKey") as! String
            return RequestConfig<[PhotoApiModel]>(request: PhotoRequest(key: apiKey, limit: 40), parser: PhotoParser())
        }
        
    }
    
    
}
