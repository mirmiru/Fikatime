//
//  Cafe.swift
//  FikaTime
//
//  Created by Milja V on 2018-04-20.
//  Copyright © 2018 Milja V. All rights reserved.
//

import Foundation

struct CafeReview {
    //dict: user: review
    let review: [String: String]
}

struct CafeImage {
    //dict: user: image
    let cafeImage: [String: String]
}

struct Cafe {
    var id: String?
    var name: String?
    var rating: Double?
    //let allReviews: [CafeReview]?
    //let allImages: [CafeImage]?
    
    
    init(id: String? = nil, name: String? = nil, rating: Double? = nil) {
        self.id = id
        self.name = name
        self.rating = rating
    }
}




