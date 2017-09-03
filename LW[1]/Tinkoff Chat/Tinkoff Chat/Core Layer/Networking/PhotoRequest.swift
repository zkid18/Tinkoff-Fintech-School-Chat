//
//  File.swift
//  class_project
//
//  Created by Даниил on 08.05.17.
//  Copyright © 2017 Даниил. All rights reserved.
//

import Foundation

protocol IRequest {
    var urlString: URL { get }
}

class PhotoRequest: IRequest {
    
    let baseUrl: String = "api.500px.com"
    let apiMethod: String = "/v1/photos"
    let apiKey: String
    let limit: Int
    
    
    init(key: String, limit: Int) {
        self.apiKey = key
        self.limit = limit
    }
    
    var urlString: URL {
        
        let params = [
            "feature": "popular",
            "sort": "rating",
            "rpp": String(limit),
            "image_size" : "3",
            "consumer_key" : apiKey
        ]
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = baseUrl
        urlComponents.path = apiMethod
        urlComponents.queryItems = params.map { key, value in URLQueryItem(name: key, value: value) }
        
        return urlComponents.url!
    }

}
