//
//  SegmentedViewController.swift
//  FikaTime
//
//  Created by Milja V on 2018-04-26.
//  Copyright © 2018 Milja V. All rights reserved.
//

import UIKit

class SegmentedViewController: UIViewController {

    @IBOutlet weak var viewContainer: UIView!
    
    var segmentedViews: [UIView]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
    }
    
    func setUpViews() {
        segmentedViews = [UIView]()
        segmentedViews.append(MapViewController().view)
        segmentedViews.append(TableViewController().view)
        
        for view in segmentedViews {
            viewContainer.addSubview(view)
        }
        viewContainer.bringSubview(toFront: segmentedViews[0])
    }

    @IBAction func swipeToReturn(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }

    @IBAction func changeSegment(_ sender: UISegmentedControl) {
        self.viewContainer.bringSubview(toFront: segmentedViews[sender.selectedSegmentIndex])
    }
}
