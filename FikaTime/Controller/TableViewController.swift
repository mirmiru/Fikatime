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

    var allFoundCafes = [Cafe]()
    var allRatings = [Double]()
    var ref: DatabaseReference!
    var databaseHandle: DatabaseHandle!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        databaseListener {
            self.tableView.reloadData()
        }
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellTable")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allFoundCafes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellTable", for: indexPath) as UITableViewCell
        if let name = allFoundCafes[indexPath.row].name,
            let rating = allFoundCafes[indexPath.row].rating {
            cell.textLabel?.text = "\(name) (\(rating) ★)"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let destination = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailView") as! DetailViewController
        if let id = allFoundCafes[indexPath.row].id {
            destination.cafeId = id
        }
        self.present(destination, animated: true, completion: nil)
    }
    
    func databaseListener(finished: @escaping () -> Void) {
        ref = Database.database().reference()
        databaseHandle = ref.child("cafes").queryOrdered(byChild: "name").observe(.value, with: { (snapshot) in
            self.allFoundCafes.removeAll()
            for child in snapshot.children.allObjects {
                print(child)
                let snap = child as! DataSnapshot
                var cafe = Cafe()
                cafe.id = snap.key
                
                if let dict = snap.value as? [String: Any] {
                    let name = dict["name"] as! String
                    cafe.name = name
                }
                
                self.loadRating(cafe: snap, finished: {
                    let sum = self.allRatings.reduce(0) { $0 + $1 }
                    let average = sum/Double(self.allRatings.count)
                    cafe.rating = average.roundTo(decimals: 1)
                    self.allFoundCafes.append(cafe)
                    self.allRatings.removeAll()
                    self.tableView.reloadData()
                })
            }
            finished()
        })
    }

    func loadRating(cafe: DataSnapshot, finished: @escaping () -> ()) {
        Database.database().reference().child("ratings").child(cafe.key).observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                if let r = snap.value as? Double {
                    self.allRatings.append(r)
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

    func sortData(array: [Cafe]) -> [Cafe] {
        return array.sorted(by: { $0.name! < $1.name!})
    }
}
