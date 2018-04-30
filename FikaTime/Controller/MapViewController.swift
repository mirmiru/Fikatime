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
    
    var allCafes: [Cafe]!
    
    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAllCafes()
        OperationQueue.main.addOperation {
            self.locationManager.requestWhenInUseAuthorization()
        }
        setUpMap()
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
    
    func getAllCafes() {
        //Get all cafes in database
        
        ref = Database.database().reference()
            databaseHandle = ref.child("cafes").observe(.value, with: { (snapshot) in
                //self.allCafes.removeAll()
                for child in snapshot.children.allObjects {
                    let snap = child as! DataSnapshot
                    print("SNAPP: \(snap)")
                    if let dict = snap.value as? [String: String] {
                        
                        /*
                        if let name = dict["name"] {
                            self.allCafes.append(name)
                        } else {
                            print("No name found.")
                        }
                        */
                    }
                }
            })
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
