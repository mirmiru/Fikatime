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
        // Do any additional setup after loading the view.
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

    @IBAction func changeSegment(_ sender: UISegmentedControl) {
        //When user clicks on segmentcontroller
        self.viewContainer.bringSubview(toFront: segmentedViews[sender.selectedSegmentIndex])
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
