//
//  LocalDatabase.swift
//  FikaTime
//
//  Created by Milja V on 2018-04-20.
//  Copyright © 2018 Milja V. All rights reserved.
//

import Foundation
import FirebaseDatabase

/*
struct DataStorage {
 
    //Receive data and create a cafe dictionary holding said data
    func saveCafe(name: String, rating: Double, review: String){
        let cafeData : [String: Any] =
            [
                "name": name,
                "rating": rating,
                "review": review
        ]
        
        save(cafeData)
    }
    
    //Save dictionary to local database
    func save(_ cafe: [String: Any]) {
    }

    
    var cafes = UserDefaults.standard.array(forKey: "savedData") as? [Cafe]
    var savedData = UserDefaults.standard.array(forKey: "savedData") as? [Cafe]
    
    mutating func saveData(cafe: Cafe) {
        if cafes != nil {
            cafes?.append(cafe)
        } else {
            cafes = [cafe]
        }
        UserDefaults.standard.removeObject(forKey: "savedData")
        UserDefaults.standard.set(cafes, forKey: "savedData")
    }
    
    func loadData() -> [Cafe] {
        if let saved = UserDefaults.standard.array(forKey: "savedData") as? [Cafe] {
            return saved
        } else {
            return []
        }
    }
}
*/
