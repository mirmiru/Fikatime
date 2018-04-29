//
//  MainViewController.swift
//  FikaTime
//
//  Created by Milja V on 2018-04-20.
//  Copyright © 2018 Milja V. All rights reserved.
//

import UIKit
import FirebaseDatabase

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //DUMMY DATA
    var dummydata : [String] = []
    
    //Firebase
    var ref: DatabaseReference!
    var database: DataStorage!
    var databaseHandle: DatabaseHandle?

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        databaseListener()
    }
    
    //MARK: - DATABASE LISTENER

    func databaseListener() {
        ref = Database.database().reference()
        
        //Retrieve data AND listen for changes
       databaseHandle = ref.child("cafes").observe(.value) { (snapshot) in
            self.dummydata.removeAll()
            //Code to execute when update
            //Take all values and add to array
            for child in snapshot.children.allObjects {
                let snap = child as! DataSnapshot
                if let dict = snap.value as? [String: Any] {
                    let name = dict["name"] as! String
                    self.dummydata.append(name)
                }
                self.tableView.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - TABLE
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dummydata.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellMain")
        cell?.textLabel?.text = dummydata[indexPath.row]
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
