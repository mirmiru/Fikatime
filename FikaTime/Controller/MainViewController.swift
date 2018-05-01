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
    //var dummydata : [String] = []
    var testArray = [Cafe]()
    
    //Firebase
    var ref: DatabaseReference!
    //var database: DataStorage!
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
            self.testArray.removeAll()
            for child in snapshot.children.allObjects {
                let snap = child as! DataSnapshot
                
                print("SNAP: \(snap.key)")
                var cafe = Cafe()
                cafe.id = snap.key
                
                if let dict = snap.value as? [String: Any] {
                    let name = dict["name"] as! String
                    
                    cafe.name = name
                    self.testArray.append(cafe)
                    
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
        return testArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellMain")
        cell?.textLabel?.text = testArray[indexPath.row].name
        return cell!
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? DetailViewController {
            if let index = tableView.indexPathForSelectedRow?.row {
                destinationVC.cafeId = testArray[index].id
            }
        }
    }

}
