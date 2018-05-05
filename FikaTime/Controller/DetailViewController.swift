//
//  DetailViewController.swift
//  FikaTime
//
//  Created by Milja V on 2018-04-20.
//  Copyright © 2018 Milja V. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
import FirebaseStorage

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var wifiIcon: UIImageView!
    @IBOutlet weak var vegIcon: UIImageView!
    @IBOutlet weak var toiletIcon: UIImageView!
    
    //Firebase
    var ref: DatabaseReference!
    var storage = Storage.storage()
    var databaseHandle: DatabaseHandle?
    
    //Variables
    var allReviews = [Review]()
    var cafeData = Cafe()
    var testValue: String?
    var cafeId: String!
    var cafeName: String?
    var cafeAddress: String?
    var testArray = [UIImage]()
    var frame = CGRect(x: 0, y: 0, width: 0, height: 0)

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
        
        scrollView.bringSubview(toFront: pageControl)
        self.navigationController?.isNavigationBarHidden = true
        
        //TEST
        print("Received ID: \(cafeId)")
        
        loadValues(id: cafeId) {
                print("GETLOCATION")
        }
        
        setUpTableView()
        getUrls()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func mainButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - TABLEVIEW
    
    func setUpTableView() {
        tableview.delegate = self
        tableview.dataSource = self
        tableview.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableview.frame.size.width, height: 1))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allReviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "cellDetail")
        cell?.textLabel?.text = allReviews[indexPath.row].review
        cell?.detailTextLabel?.text = allReviews[indexPath.row].user
        return cell!
    }
    
    // MARK: - LOAD DATA

    func loadValues(id: String, finished: @escaping () -> Void) {
        Database.database().reference().child("cafes").child(id).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                if let name = dict["name"] as? String,
                    let lat = dict["latitude"] as? Double,
                    let long = dict["longitude"] as? Double,
                    let details = dict["details"] as? [String: Int] {
                        self.cafeName = name
                        self.name.text = self.cafeName
                        self.cafeData.coordinates.latitude = lat
                        self.cafeData.coordinates.longitude = long
                    
                    DispatchQueue.main.async {
                        self.name.text = name
                        self.getLocation(lat: lat, long: long)
                        if details["hasWifi"] == 1 {
                            self.wifiIcon.image = #imageLiteral(resourceName: "icon_wifi_1")
                        }
                        if details["hasVegan"] == 1 {
                            self.vegIcon.image = #imageLiteral(resourceName: "icon_vegan_1")
                        }
                        if details["hasToilet"] == 1 {
                            self.toiletIcon.image = #imageLiteral(resourceName: "icon_toilet_1")
                        }
                    }
                }
            }
        })

        Database.database().reference().child("reviews").child(cafeId).observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let r = Review(user: snap.key, review: snap.value as! String)
                self.allReviews.append(r)
            }
            self.tableview.reloadData()
        })
    }
    
    // MARK: - SCROLLVIEW
    
    func setUpScrollView() {
        pageControl.numberOfPages = testArray.count
        
        for index in 0..<testArray.count {
            frame.origin.x = scrollView.frame.size.width * CGFloat(index)
            frame.size = scrollView.frame.size
            
            let imageView = UIImageView(frame: frame)
            imageView.contentMode = UIViewContentMode.scaleAspectFill
            imageView.image = testArray[index]
            
            self.scrollView.addSubview(imageView)
        }
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(testArray.count), height: scrollView.frame.size.height)
        scrollView.delegate = self
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNr = scrollView.contentOffset.x / scrollView.frame.size.width
        pageControl.currentPage = Int(pageNr)
    }
    
    func downloadImage(from url: String) {
        let imageURL = URLRequest(url: URL(string: url)!)
        let task = URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
            if error != nil {
                print(error)
                return
            }
            DispatchQueue.main.async {
                if let image = UIImage(data: data!) {
                    self.testArray.append(image)
                    print(self.testArray)
                    self.setUpScrollView()
                }
            }
        }
        task.resume()
    }
    
    func getLocation(lat: Double, long: Double) {
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: lat, longitude: long)
        geoCoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let placemark = placemarks?.last {
                if let streetName = placemark.thoroughfare,
                    let streetNr = placemark.subThoroughfare,
                    let locCity = placemark.locality,
                    let adminArea = placemark.administrativeArea {
                    self.cafeAddress = "\(streetName) \(streetNr), \(locCity), \(adminArea)"
                    DispatchQueue.main.async {
                        self.locationLabel.text = self.cafeAddress
                    }
                }
            }
        }
    }
    
    func getUrls() {
        Database.database().reference().child("images").child(self.cafeId).observeSingleEvent(of: .value) { (snapshot) in
            for child in snapshot.children {
                if let snap = child as? DataSnapshot {
                    print("SNAP: \(snap)")
                    
                    if let url = snap.value as? String {
                        print("URL \(url)")

                        self.downloadImage(from: url)
                        
                        let storageRef = self.storage.reference(forURL: url)
                        storageRef.getData(maxSize: 1024*1024, completion: { (data, error) in
                            if error != nil {
                                print("Error")
                            } else {
                                if let image = UIImage(data: data!) {
                                    self.testArray.append(image)
                                    print(self.testArray)
                                }
                            }
                        })
                    }
                }
            }
        }
    }
    
    // MARK: - SWIPE
    
    @IBAction func swipeToReturn(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? AddReviewViewController {
            destinationVC.cafeId = self.cafeId
            destinationVC.cafeName = self.cafeName
            destinationVC.cafeLocation = self.cafeAddress
        }
    }
}


