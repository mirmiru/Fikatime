//
//  AddViewController.swift
//  FikaTime
//
//  Created by Milja V on 2018-04-22.
//  Copyright © 2018 Milja V. All rights reserved.
//

import UIKit
import FirebaseDatabase

class AddViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageImageview: UIImageView!
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var reviewTextview: UITextView!
    @IBOutlet weak var photoButton: UIButton!
    
    //Cafe data
    var enteredName : String?
    var enteredReview : String?
    
    //Firebase database
    var ref:DatabaseReference!
    var database: DataStorage!
    
    //Database variables
    let NODE_CAFES = "cafes"
    let NODE_RATINGS = "ratings"
    let NODE_REVIEWS = "reviews"
    
    let KEY_NAME = "name"
    let KEY_USER = "user"       //TODO: Replace with users id
    
    override func viewDidLoad() {
        super.viewDidLoad()
        database = DataStorage()
        photoButton.roundedButton()
        
        ref = Database.database().reference()
        
        //CAMERA
        if let image = UIImage(contentsOfFile: cachedImagePath) {
            imageImageview.image = image
        } else {
            NSLog("No cached image found.")
        }
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
    }
    
    @IBAction func saveButtonClick(_ sender: Any) {
        grabData()
        
        //Store unique id for later use AND update database
        let newCafeRef = ref.child(NODE_CAFES).childByAutoId()
        newCafeRef.child(KEY_NAME).setValue(enteredName)
        print(newCafeRef.key)
        
        //Store review
        ref.child(NODE_REVIEWS).child(newCafeRef.key).child(KEY_USER).setValue(enteredReview)
        
        //Store rating
        ref.child(NODE_RATINGS).child(newCafeRef.key).child(KEY_USER).setValue(4.5)
        
        //Store photo
        ref.child("images").child(newCafeRef.key).child(KEY_USER).setValue("filepath")
        
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
