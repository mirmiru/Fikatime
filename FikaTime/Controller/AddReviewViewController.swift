//
//  AddReviewViewController.swift
//  FikaTime
//
//  Created by Milja V on 2018-05-02.
//  Copyright © 2018 Milja V. All rights reserved.
//

import UIKit

class AddReviewViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var reviewTextView: UITextView!

    
    var cafeId: String!
    var cafeName: String!
    var cafeLocation: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        setViews()
        // Do any additional setup after loading the view.
    }
    
    func setViews() {
        nameLabel.text = cafeName
        locationLabel.text = "Address non static."
    }

    @IBAction func undoButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // TODO: - Function for adding data

}
