//
//  CreateExchangeCenters.swift
//  Currency_Exchange
//
//  Created by Даниил on 22.02.17.
//  Copyright © 2017 Даниил. All rights reserved.
//

import Foundation
import MapKit

class CreateExchangeCenters {
    
    static let shared = CreateExchangeCenters()
    
    var exchangeCenters = [ExchangeCenter(title: "Сбербанк", coordinate: CLLocationCoordinate2D(latitude: 55.851244, longitude: 37.518423)), ExchangeCenter(title: "Альфа-банк", coordinate: CLLocationCoordinate2D(latitude: 55.751244, longitude: 37.618423))]
    
}
