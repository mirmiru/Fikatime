//
//  AddReviewViewController.swift
//  FikaTime
//
//  Created by Milja V on 2018-05-02.
//  Copyright © 2018 Milja V. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import Cosmos

class AddReviewViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var reviewTextView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var ratingBar: CosmosView!
    
    let ref = Database.database().reference()
    let storage = Storage.storage()
    
    var cafeId: String!
    var cafeName: String!
    var cafeLocation: String!

    //Database variables
    let NODE_IMAGES = "images"
    let NODE_RATINGS = "ratings"
    let NODE_REVIEWS = "reviews"
    let KEY_USER = "UserName"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        print("Got ID \(cafeId)")
    }
    
    func setUp() {
        reviewTextView.delegate = self
        saveButton.center = CGPoint(x: containerView.bounds.size.width/2, y: containerView.bounds.size.height)
        saveButton.roundedCorners()
        photoButton.roundButton()
        nameLabel.text = cafeName
        //locationLabel.text = cafeLocation
    }
    
    @IBAction func cameraButtonClicked(_ sender: Any) {
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
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("Editing!")
        reviewTextView.text = ""
    }
    
    var cachedImagePath: String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory.appending("/cached.png")
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        imageView.image = editedImage
        
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
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        uploadData()
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - SAVE DATA
    
    func uploadData() {
        ref.child(NODE_RATINGS).child(self.cafeId).child(KEY_USER).setValue(ratingBar.rating)
        ref.child(NODE_REVIEWS).child(self.cafeId).child(KEY_USER).setValue(reviewTextView.text)
        
        let imageName = NSUUID().uuidString
        let storageRef = storage.reference().child("\(imageName).png")
        if let uploadData = UIImagePNGRepresentation(imageView.image!) {
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(error)
                    return
                } else {
                    if let imageUrl = metadata?.downloadURL()?.absoluteString {
                        //TODO: FIX STATIC VALUE FOR USER
                        print("ID \(self.cafeId)")
                        print("IMG URL \(imageUrl)")
                        print("REF \(self.ref)")
                        self.ref.child(self.NODE_IMAGES).child(self.cafeId).child(self.KEY_USER).setValue(imageUrl)
                    }
                }
            })
        }
        dismiss(animated: true, completion: nil)
    }

    @IBAction func undoButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
