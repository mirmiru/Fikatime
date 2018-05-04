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
    
    var testArray = [Cafe]()
    var rating: Double!
    
    //Firebase
    var ref: DatabaseReference!
    var databaseHandle: DatabaseHandle?

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        databaseListener()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //testArray.removeAll()
    }
    
    //MARK: - DATABASE LISTENER

    func databaseListener() {
        self.testArray.removeAll()
        
        ref = Database.database().reference()
        
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
                }
                
                self.loadRating(cafe: snap, finished: {
                    cafe.rating = self.rating
                    print("GOT RATING: \(cafe.rating)")
                    self.testArray.append(cafe)
                    self.testArray = self.sortData()
                    self.tableView.reloadData()
                })
            }
        }
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - TABLE
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return testArray.count
    }
    
    /*
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "segueDetail", sender: indexPath)
    }
 */
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellMain")
        if let rating = testArray[indexPath.row].rating,
            let text = testArray[indexPath.row].name {
            cell?.textLabel?.text = text
            cell?.detailTextLabel?.text = "\(rating) ★"
        }
        return cell!
    }
    
    func sortData() -> [Cafe] {
        testArray.sort(by: { $0.rating! > $1.rating! })
        
        //More than 5 cafes
        if testArray.count > 5 {
            var finalArray = [Cafe]()
            for i in 0...4 {
                finalArray.append(testArray[i])
            }
            return finalArray
        }
        return testArray
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destinationVC = segue.destination as? DetailViewController {
            if let index = tableView.indexPathForSelectedRow?.row {
                destinationVC.cafeId = testArray[index].id
                destinationVC.testValue = testArray[index].name
            }
        }
        
        /*
        if (segue.identifier == "segueDetail") {
            let destination = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailView") as! DetailViewController
        
//            if let destination = segue.destination as? DetailViewController {
                if let index = sender as? IndexPath {
                    print("SEGUE: \(testArray[index.row].id)")
                    destination.cafeId = testArray[index.row].id
                }
        }
 */
    }
 

}
