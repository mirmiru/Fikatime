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
    
    //Firebase
    var ref: DatabaseReference!
    var database: DataStorage!
    var databaseHandle: DatabaseHandle?
    
    var reviewsData : [[String: String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.delegate = self
        tableview.dataSource = self
        image.rounded()
        containerView.setShadow(color: UIColor.lightGray.cgColor, opacity: 1, offset: CGSize.zero, radius: 5)
        // Do any additional setup after loading the view.
        
        databaseListener()
    }
    
    func databaseListener() {
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Tableview
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviewsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "cellDetail")
        cell?.textLabel?.text = reviewsData[indexPath.row]["user"]
        return cell!
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
