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
    var clickedAnnotation: CustomAnnotation!
    let ref = Database.database().reference()
    var databaseHandle: DatabaseHandle!
    var allCafes = [Cafe]()
    var rating: Double!

    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        OperationQueue.main.addOperation {
            self.locationManager.requestWhenInUseAuthorization()
        }
        map.delegate = self
        setUpMap()
        testFunc {
            print("Doing more stuff")
        }
    }
    
    func setUpMap() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadRating(cafe: DataSnapshot, finished: @escaping () -> ()) {
        Database.database().reference().child("ratings").child(cafe.key).observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                if let r = snap.value as? Double {
                    self.rating = r
                } else {
                    print("No rating found.")
                }
            }
            finished()
        })
    }
    
    func testFunc(finished: @escaping () -> Void) {
        //ref = Database.database().reference()
        databaseHandle = ref.child("cafes").observe(.value, with: { (snapshot) in
            for child in snapshot.children.allObjects {
                let snap = child as! DataSnapshot
                let id = snap.key
                
                if let dict = snap.value as? [String: Any],
                    let name = dict["name"] as? String,
                    let lat = dict["latitude"] as? Double,
                    let long = dict["longitude"] as? Double {

                    //Get rating
                    self.loadRating(cafe: snap, finished: {
                        let cafe = Cafe(id: id, name: name, rating: self.rating, lat: lat, long: long)
                        print("ADDING CAFE: \(cafe)")
                        self.allCafes.append(cafe)
                        
                        //Create annotations
                        self.createAnnotations()
                    })
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
            let annotation = CustomAnnotation()
            annotation.title = c.name
            if let rating = c.rating {
                annotation.subtitle = "\(rating) ★"
            }
            annotation.id = c.id
            annotation.coordinate = CLLocationCoordinate2DMake(c.coordinates.latitude, c.coordinates.longitude)
            self.map.addAnnotation(annotation)
            print("Added annotation \(annotation)")
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "pin"
        var view: MKMarkerAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -1, y: 1)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView {
            clickedAnnotation = view.annotation as? CustomAnnotation
            //performSegue(withIdentifier: "segueDetail", sender: self)
            
            //Prepare for segue to detail view
            if let destination = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailView") as? DetailViewController {
                destination.cafeId = clickedAnnotation.id
                self.present(destination, animated: true, completion: nil)
            }
        }
    }
    
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueDetail" {
            
            /*
            if let destination = segue.destination as? DetailViewController {
                destination.cafeId = clickedAnnotation.id
            }
 */
        }
    }
 */
}

class CustomAnnotation: MKPointAnnotation {
    var id: String?
}


