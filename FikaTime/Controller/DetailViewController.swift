//
//  DetailViewController.swift
//  FikaTime
//
//  Created by Milja V on 2018-04-20.
//  Copyright © 2018 Milja V. All rights reserved.
//

import UIKit
import FirebaseDatabase

//VILKEN MODEL?
//Databasen - hämta enskild cafe data

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    //Firebase
    var ref: DatabaseReference!
    var database: DataStorage!
    var databaseHandle: DatabaseHandle?
    var allReviews = [Review]()
    
    //Variables
    var cafeId: String!
    
    struct Review {
        var user: String
        var review: String
        
        init(user: String, review: String) {
            self.user = user
            self.review = review
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TEST
        print("Received ID: \(cafeId)")
        loadValues(id: cafeId)
        
        tableview.delegate = self
        tableview.dataSource = self
        image.rounded()
        containerView.setShadow(color: UIColor.lightGray.cgColor, opacity: 1, offset: CGSize.zero, radius: 5)
        // Do any additional setup after loading the view.
        
        databaseListener()
    }
    
    func databaseListener() {
        /*
        ref = Database.database().reference()
        
        databaseHandle = ref.child("reviews").observe(.value) { (snapshot) in
            for child in snapshot.children.allObjects {
                let snap = child as! DataSnapshot
                if let dict = snap.value as? [String: String] {
                    print(dict)
                    self.reviewsData.append(dict)
                }
            self.tableview.reloadData()
            }
        }
 */
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Tableview
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allReviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "cellDetail")
        cell?.textLabel?.text = allReviews[indexPath.row].review
        return cell!
    }
    
    // MARK: - LOAD DATA
    
    func loadValues(id: String) {
        Database.database().reference().child("cafes").child(cafeId).observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                self.name.text = dict["name"] as? String
            }
        }
        
        Database.database().reference().child("reviews").child(cafeId).observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let r = Review(user: snap.key, review: snap.value as! String)
                self.allReviews.append(r)
            }
            self.tableview.reloadData()
        })
    }
}
