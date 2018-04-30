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

    var cafeList = [String]()
    var ref: DatabaseReference!
    var databaseHandle: DatabaseHandle!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        loadData()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellTable")

        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cafeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellTable", for: indexPath)
        cell.textLabel?.text = cafeList[indexPath.row]
        return cell
    }
    
    func loadData() {
        ref = Database.database().reference()
        databaseHandle = ref.child("cafes").observe(.value, with: { (snapshot) in
            self.cafeList.removeAll()
            for child in snapshot.children.allObjects {
                let snap = child as! DataSnapshot
                if let dict = snap.value as? [String: String] {
                    if let name = dict["name"] {
                        self.cafeList.append(name)
                    } else {
                        print("No name found.")
                    }
                }
                self.tableView.reloadData()
            }
        })
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
