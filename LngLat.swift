//
//  LngLat.swift
//  aspace
//
//  Created by Fedor Paretsky on 10/29/18.
//  Copyright © 2018 aspace, Inc. All rights reserved.
//

import Foundation

struct LngLat {
    let lng, lat: Double
    let name: String
    
    init(lng: Double, lat: Double, name: String) {
        self.lng = lng
        self.lat = lat
        self.name = name
    }
    
    init(lng: Double, lat: Double) {
        self.lng = lng
        self.lat = lat
        self.name = ""
    }
}
