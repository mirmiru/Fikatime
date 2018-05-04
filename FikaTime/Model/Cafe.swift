//
//  Cafe.swift
//  FikaTime
//
//  Created by Milja V on 2018-04-20.
//  Copyright © 2018 Milja V. All rights reserved.
//

import Foundation

struct CafeReview {
    var user: String
    var review: String
}

/*
struct CafeCoordinates {
    var latitude: Double
    var longitude: Double
}
 */

struct CafeImage {
    //dict: user: image
    let cafeImage: [String: String]
}

struct Cafe {
    var id: String?
    var name: String?
    var rating: Double?
    var coordinates: CafeCoordinates
    
    struct CafeCoordinates {
        var latitude: Double
        var longitude: Double
    }
    
    
    init(id: String? = nil, name: String? = nil, rating: Double? = nil, lat: Double = 0, long: Double = 0) {
        self.id = id
        self.name = name
        self.rating = rating
        self.coordinates = CafeCoordinates(latitude: lat, longitude: long)
    }
}




