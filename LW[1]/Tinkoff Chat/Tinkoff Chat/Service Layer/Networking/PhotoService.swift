//
//  PhotoService.swift
//  class_project
//
//  Created by Даниил on 08.05.17.
//  Copyright © 2017 Даниил. All rights reserved.
//

import Foundation

protocol IPhotoService {
    func loadPopularPhotos(completionHandler: @escaping ([PhotoApiModel]?, String?) -> Void)
}

class PhotoService {
    
    let requestSender: IRequestSender
    
    init() {
        self.requestSender = RequestSender()
    }
    
    func loadPopularPhotos(completionHandler: @escaping ([PhotoApiModel]?, String?) -> Void) {
        
        let requestConfig: RequestConfig<[PhotoApiModel]> = RequstFactory.PhotosRequests.photosConfig()
        requestSender.send(config: requestConfig) { (result: Result<[PhotoApiModel]>) in
            switch result {
            case .Success(let photos):
                print(photos.count)
                completionHandler(photos, nil)
            case .Fail(let error):
                completionHandler(nil, error)
            }
        }
    }
    
}
