//
//  Cafe.swift
//  FikaTime
//
//  Created by Milja V on 2018-04-20.
//  Copyright © 2018 Milja V. All rights reserved.
//

import Foundation

struct Cafe {
    //var id: String?
    var name: String
    var rating: Int
    var review: String
    var allReviews: [String]?   //make this into dictionary array to hold user: review data?
    //var imageFilepath: String?
    
    init(name: String, rating: Int, review: String) {
        self.name = name
        self.review = review
        self.rating = rating
        
        if allReviews != nil {
            allReviews?.append(review)
        } else {
            allReviews = [review]
        }
    }
}




