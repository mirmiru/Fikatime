//
//  TestViewController.swift
//  FikaTime
//
//  Created by Milja V on 2018-05-02.
//  Copyright © 2018 Milja V. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class TestViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var dataArray: [URL]!
    //var images : [UIImage] = [#imageLiteral(resourceName: "cafe01"), #imageLiteral(resourceName: "cafe02"), #imageLiteral(resourceName: "cafe03")]
    var testArray = [UIImage]()
    var frame = CGRect(x: 0, y: 0, width: 0, height: 0)
    
    var ref: DatabaseReference!
    let storage = Storage.storage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUrls()
    }
    
    func setUpScrollView() {
        pageControl.numberOfPages = testArray.count
        
        for index in 0..<testArray.count {
            frame.origin.x = scrollView.frame.size.width * CGFloat(index)
            frame.size = scrollView.frame.size
            
            let imageView = UIImageView(frame: frame)
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
                print("Errorrrr \(error)")
                return
            }
            
            DispatchQueue.main.async {
                print("Dispatch")
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
