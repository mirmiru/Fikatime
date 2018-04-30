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
    
    //Cafe data
    var enteredName : String?
    var enteredReview : String?
    var enteredImage : UIImage?
    var enteredRating: Double?
    var lat: Double?
    var long: Double?
    
    //Location
    lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        return manager
    }()
    
    //Firebase database and storage
    var ref:DatabaseReference!
    var database: DataStorage!
    let storage = Storage.storage()
    
    //Database variables
    let NODE_CAFES = "cafes"
    let NODE_RATINGS = "ratings"
    let NODE_REVIEWS = "reviews"
    
    let KEY_NAME = "name"
    let KEY_USER = "user"       //TODO: Replace with user's id
    let KEY_LAT = "latitude"
    let KEY_LONG = "longitude"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        database = DataStorage()
        photoButton.roundedButton()
        containerView.setShadow(color: UIColor.darkGray.cgColor, opacity: 1, offset: CGSize.zero, radius: 10)
        
        ref = Database.database().reference()
        
        //CAMERA
        if let image = UIImage(contentsOfFile: cachedImagePath) {
            imageImageview.image = image
            enteredImage = image
        } else {
            NSLog("No cached image found.")
        }
    }
    
    //Get current location
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
        print("Thoroughfare: \(placemark.thoroughfare)")
        print("Subthoroughfare: \(placemark.subThoroughfare)")
        print("Locality: \(placemark.locality)")
        print("County \(placemark.country)")
        
        //Save lat & long
        lat = placemark.location?.coordinate.latitude
        long = placemark.location?.coordinate.longitude
        
        //print("Lat: \(placemark.location?.coordinate.latitude)")
        //print("Long: \(placemark.location?.coordinate.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error receiving location.")
    }
    
    var cachedImagePath: String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory.appending("/cached.png")
    }
    
    @IBAction func onPhotoButtonClick(_ sender: Any) {
        //Take photo/access gallery
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
    
    @IBAction func saveButtonClick(_ sender: Any) {
        grabData()
        
        //Store unique id for later use AND update database
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
                        self.ref.child("images").child(CAFE_ID.key).child(self.KEY_USER).setValue(imageUrl)
                    }
                }
            })
        }
        dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
