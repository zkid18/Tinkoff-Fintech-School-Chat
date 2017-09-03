//
//  ExchangeCenter.swift
//  Currency_Exchange
//
//  Created by Даниил on 22.02.17.
//  Copyright © 2017 Даниил. All rights reserved.
//

import Foundation
import MapKit

class ExchangeCenter: NSObject, MKAnnotation {
    
    let title: String?
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
        
        super.init()
    }
    
}
