//
//  PhotoParser.swift
//  class_project
//
//  Created by Даниил on 08.05.17.
//  Copyright © 2017 Даниил. All rights reserved.
//

import Foundation

class Parser<T> {
    func parse(data: Data) -> T? { return nil }
}

struct PhotoApiModel {
    let name: String
    let url: String
}

class PhotoParser: Parser<[PhotoApiModel]> {
    override func parse(data: Data) -> [PhotoApiModel]? {
        
        do {
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] else { return nil }
            
            guard let photos = json["photos"] as? [[String: Any]] else {return nil}
            
            print(photos)
            
            var apiPhotos: [PhotoApiModel] = []
            
            for photo in photos {
                guard let name = photo["name"] as? String,
                    let imageUrl = photo["image_url"] as? String
                    else {continue}
                apiPhotos.append(PhotoApiModel(name: name, url: imageUrl))
            }
            return apiPhotos
            
        } catch  {
            print("error trying to convert data to JSON")
            return nil
        }
    }
}
