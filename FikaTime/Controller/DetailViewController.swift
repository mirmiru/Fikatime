//
//  DetailViewController.swift
//  FikaTime
//
//  Created by Milja V on 2018-04-20.
//  Copyright © 2018 Milja V. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

//VILKEN MODEL?
//Databasen - hämta enskild cafe data

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    //Firebase
    var ref: DatabaseReference!
    var storage = Storage.storage()
    var databaseHandle: DatabaseHandle?
    var allReviews = [Review]()
    
    //Variables
    var cafeId: String!
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
        loadValues(id: cafeId)
        
        tableview.delegate = self
        tableview.dataSource = self
        containerView.setShadow(color: UIColor.lightGray.cgColor, opacity: 1, offset: CGSize.zero, radius: 5)
        
        getUrls()
        //databaseListener()
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
    
    @IBAction func mainButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - TABLEVIEW
    
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
    
    func getUrls() {
        Database.database().reference().child("images").child("-LBMKiKn46ahlEu2dNrf").observeSingleEvent(of: .value) { (snapshot) in
            for child in snapshot.children {
                if let snap = child as? DataSnapshot {
                    print("SNAP: \(snap)")
                    
                    if let url = snap.value as? String {
                        print("URL \(url)")
                        
                        //TEST
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
            destinationVC.cafeName = self.name.text
            //destinationVC.cafeLocation = 
        }
    }
}


