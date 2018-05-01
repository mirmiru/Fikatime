//
//  MapViewController.swift
//  FikaTime
//
//  Created by Milja V on 2018-04-26.
//  Copyright © 2018 Milja V. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseDatabase

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    let locationManager = CLLocationManager()
    var ref: DatabaseReference!
    var databaseHandle: DatabaseHandle!
    
    var allCafes = [Cafe]()
    
    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        OperationQueue.main.addOperation {
            self.locationManager.requestWhenInUseAuthorization()
        }
        map.delegate = self
        setUpMap()
        //getAllCafes()
        
        testFunc {
            print("Doing more stuff")
            self.createAnnotations()
        }
        
    }
    
    func setUpMap() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    func getAllCafes() {
        //Get all cafes in database
        
        ref = Database.database().reference()
            databaseHandle = ref.child("cafes").observe(.value, with: { (snapshot) in
                //self.allCafes.removeAll()
                for child in snapshot.children.allObjects {
                    let snap = child as! DataSnapshot
                    let id = snap.key
                    
                    //TODO: Fix rating to remove static value
                    let rating = 3.3
                    
                    if let dict = snap.value as? [String: Any],
                        let name = dict["name"] as? String,
                        let lat = dict["latitude"] as? Double,
                        let long = dict["longitude"] as? Double {
                            let cafe = Cafe(id: id, name: name, rating: rating, lat: lat, long: long)
                            print("ADDING CAFE: \(cafe)")
                            self.allCafes.append(cafe)
                    } else {
                        print("Found nil values for \(id)")
                    }
                }
            
            })
    }
 */
    
    func testFunc(finished: @escaping () -> Void) {
        print("Doing stuff")
        
        ref = Database.database().reference()
        databaseHandle = ref.child("cafes").observe(.value, with: { (snapshot) in
            //self.allCafes.removeAll()
            for child in snapshot.children.allObjects {
                let snap = child as! DataSnapshot
                let id = snap.key
                
                //TODO: Fix rating to remove static value
                let rating = 3.3
                
                if let dict = snap.value as? [String: Any],
                    let name = dict["name"] as? String,
                    let lat = dict["latitude"] as? Double,
                    let long = dict["longitude"] as? Double {
                    let cafe = Cafe(id: id, name: name, rating: rating, lat: lat, long: long)
                    print("ADDING CAFE: \(cafe)")
                    self.allCafes.append(cafe)
                } else {
                    print("Found nil values for \(id)")
                }
            }
            finished()
        })
    }
    
    func createAnnotations() {
        print("CreateAnnotations()")
        for c in allCafes {
            let annotation = MKPointAnnotation()
            annotation.title = c.name
            annotation.coordinate = CLLocationCoordinate2DMake(c.coordinates.latitude, c.coordinates.longitude)
            self.map.addAnnotation(annotation)
            print("Added annotation \(annotation)")
        }
    }

}











