//
//  AddViewController.swift
//  FikaTime
//
//  Created by Milja V on 2018-04-22.
//  Copyright © 2018 Milja V. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseDatabase
import FirebaseStorage
import Cosmos

class AddViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var imageImageview: UIImageView!
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var reviewTextview: UITextView!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var ratingBar: CosmosView!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var iconWifi: UIButton!
    @IBOutlet weak var iconVeg: UIButton!
    @IBOutlet weak var toiletIcon: UIButton!
    
    //Cafe data
    var enteredName: String?
    var enteredReview: String?
    var enteredImage: UIImage?
    var enteredRating: Double?
    var hasWifi: Bool = false
    var hasVegan: Bool = false
    var hasToilet: Bool = false
    var lat: Double?
    var long: Double?
    var address: String?
    
    //Location
    lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        return manager
    }()
    
    let ref = Database.database().reference()
    let storage = Storage.storage()
    
    //Database
    let NODE_CAFES = "cafes"
    let NODE_IMAGES = "images"
    let NODE_RATINGS = "ratings"
    let NODE_REVIEWS = "reviews"
    let NODE_DETAILS = "details"
    let KEY_NAME = "name"
    let KEY_USER = "user"       //TODO: Extend app by replacing static value with login user id
    let KEY_LAT = "latitude"
    let KEY_LONG = "longitude"
    let KEY_WIFI = "hasWifi"
    let KEY_VEG = "hasVegan"
    let KEY_TOILET = "hasToilet"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    func setUp() {
        photoButton.roundButton()
        containerView.bringSubview(toFront: saveButton)
        saveButton.roundedCorners()
        saveButton.center = CGPoint(x: containerView.bounds.size.width/2, y: containerView.bounds.size.height)
        containerView.setShadow(color: UIColor.lightGray.cgColor, opacity: 1, offset: CGSize.zero, radius: 5)
    }
    
    @IBAction func wifiPressed(_ sender: Any) {
        if iconWifi.isChosen() {
            iconWifi.setBackgroundImage(#imageLiteral(resourceName: "icon_wifi_1"), for: .selected)
            hasWifi = true
        } else {
            iconWifi.setBackgroundImage(#imageLiteral(resourceName: "icon_wifi_0"), for: .normal)
            hasWifi = false
        }
    }
    
    @IBAction func vegPressed(_ sender: Any) {
        if iconVeg.isChosen() {
            iconVeg.setBackgroundImage(#imageLiteral(resourceName: "icon_vegan_1"), for: .selected)
            hasVegan = true
        } else {
            iconVeg.setBackgroundImage(#imageLiteral(resourceName: "icon_vegan_0"), for: .normal)
            hasVegan = false
        }
    }
    
    @IBAction func toiletPressed(_ sender: Any) {
    }
    
    // MARK: - MAP
    
    @IBAction func getLocation(_ sender: Any) {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if case .authorizedWhenInUse = status {
            manager.requestLocation()
        } else {
            print("Current location not authorized.")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Success getting current location.")
        if let manager = locations.last {
            CLGeocoder().reverseGeocodeLocation(manager) { (placemarks, error) in
                if let places = placemarks {
                        let place = places[0]
                        self.showLocationDetails(placemark: place)
                }
            }
        }
    }
    
    func showLocationDetails(placemark: CLPlacemark) {
        locationManager.stopUpdatingLocation()
        
        if let streetName = placemark.thoroughfare,
            let streetNr = placemark.subThoroughfare,
            let locCity = placemark.locality,
            let adminArea = placemark.administrativeArea {
                address = "\(streetName) \(streetNr), \(locCity), \(adminArea)"
                locationLabel.text = self.address
            }
            lat = placemark.location?.coordinate.latitude
            long = placemark.location?.coordinate.longitude
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error receiving location.")
    }
    
    // MARK: - CAMERA
    
    var cachedImagePath: String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory.appending("/cached.png")
    }
    
    @IBAction func onPhotoButtonClick(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
        } else {
            imagePicker.sourceType = .savedPhotosAlbum
        }
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        imageImageview.image = editedImage
        
        if let data = UIImagePNGRepresentation(editedImage) {
            do {
                let url = URL(fileURLWithPath: cachedImagePath)
                try data.write(to: url)
                photoButton.isHidden = true
            } catch {
                NSLog("Write failed.")
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func grabData() {
        enteredName = nameTextfield.text
        enteredReview = reviewTextview.text
        enteredRating = ratingBar.rating
    }
    
    @IBAction func cancelButtonClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonClick(_ sender: Any) {
        grabData()
        
        //Store unique id for later use
        let CAFE_ID = ref.child(NODE_CAFES).childByAutoId()
        
        //Store name
        CAFE_ID.child(KEY_NAME).setValue(enteredName)
        
        //TEST - ID
        print("Cafe ID: \(CAFE_ID.key)")
    
        //Store lat & long
        ref.child(NODE_CAFES).child(CAFE_ID.key).child(KEY_LAT).setValue(lat)
        ref.child(NODE_CAFES).child(CAFE_ID.key).child(KEY_LONG).setValue(long)
        
        //Store review
        ref.child(NODE_REVIEWS).child(CAFE_ID.key).child(KEY_USER).setValue(enteredReview)
        
        //Store rating
        ref.child(NODE_RATINGS).child(CAFE_ID.key).child(KEY_USER).setValue(enteredRating)
        
        //Store values
        ref.child(NODE_CAFES).child(CAFE_ID.key).child(NODE_DETAILS).child(KEY_WIFI).setValue(hasWifi)
        ref.child(NODE_CAFES).child(CAFE_ID.key).child(NODE_DETAILS).child(KEY_VEG).setValue(hasVegan)
        ref.child(NODE_CAFES).child(CAFE_ID.key).child(NODE_DETAILS).child(KEY_TOILET).setValue(hasToilet)
        
        //Store photo
        let imageName = NSUUID().uuidString
        let storageRef = storage.reference().child("\(imageName).png")
        if let uploadData = UIImagePNGRepresentation(imageImageview.image!) {
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(error)
                    return
                } else {
                    print(metadata)
                    //Store image with cafe info in firebase
                    if let imageUrl = metadata?.downloadURL()?.absoluteString {
                        self.ref.child(self.NODE_IMAGES).child(CAFE_ID.key).child(self.KEY_USER).setValue(imageUrl)
                    }
                }
            })
        }
        dismiss(animated: true, completion: nil)
    }

    @IBAction func swipeDownToReturn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
