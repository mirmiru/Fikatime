//
//  TableViewController.swift
//  FikaTime
//
//  Created by Milja V on 2018-04-26.
//  Copyright © 2018 Milja V. All rights reserved.
//

import UIKit
import FirebaseDatabase

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var allCafes = [Cafe]()
    var ref: DatabaseReference!
    var databaseHandle: DatabaseHandle!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        //TEST
        databaseListener {
            print("TABLE: DATABASELISTENER FINISHED")
            self.sortData()
        }

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellTable")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allCafes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellTable", for: indexPath)
        cell.textLabel?.text = allCafes[indexPath.row].name
        return cell
    }
    
    func databaseListener(finished: @escaping () -> Void) {
    //func databaseListener() {
        ref = Database.database().reference()
        
        //Retrieve data AND listen for changes
            databaseHandle = ref.child("cafes").observe(.value, with: { (snapshot) in
            self.allCafes.removeAll()
            for child in snapshot.children.allObjects {
                let snap = child as! DataSnapshot
                
                print("DBLISTENER SNAP: \(snap.key)")
                var cafe = Cafe()
                cafe.id = snap.key
                
                if let dict = snap.value as? [String: Any] {
                    let name = dict["name"] as! String
                    cafe.name = name
                    self.allCafes.append(cafe)
                }
                self.tableView.reloadData()
            }
            finished()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func sortData() {
        print("Unsorted: \(allCafes)")
        allCafes.sort(by: { $0.name! < $1.name!})
        print("Sorted: \(allCafes)")
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
