//
//  PhotoModel.swift
//  class_project
//
//  Created by Даниил on 08.05.17.
//  Copyright © 2017 Даниил. All rights reserved.
//

import Foundation

protocol IPhotoModel {
    func fetchPhotos(completionHandler: @escaping  () -> ())
}


class PhotoModel: IPhotoModel {
    
    let photoService: PhotoService
    var photosToShow = [PhotoApiModel]()
    
    init(photoService: PhotoService) {
        self.photoService = photoService
    }
    
    func fetchPhotos(completionHandler: @escaping () -> ()) {
        
        photoService.loadPopularPhotos { (photos: [PhotoApiModel]?, error) in
            if let photos = photos {
                self.photosToShow = photos
                completionHandler()
            }
        }
    }
}
