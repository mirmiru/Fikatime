//
//  Extensions.swift
//  FikaTime
//
//  Created by Milja V on 2018-04-22.
//  Copyright © 2018 Milja V. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    func rounded() {
        self.layer.cornerRadius = self.frame.size.width/2
        self.clipsToBounds = true
    }
}

extension UIButton {
    func roundButton() {
        self.layer.cornerRadius = self.frame.size.width/2
        self.clipsToBounds = true
    }
    
    func roundedCorners() {
        self.layer.cornerRadius = 15
        self.clipsToBounds = true
    }
}

extension UIView {
    func setShadow(color: CGColor, opacity: Float, offset: CGSize, radius: CGFloat) {
        self.layer.shadowColor = color
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offset
        self.layer.shadowRadius = radius
        //self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
    }
}

extension UITextView {
    func setPlaceholder(placeholder: String) {
        self.text = placeholder
        self.textColor = UIColor.lightGray
    }
}

extension UIButton {
    func isChosen() -> Bool {
        if self.isSelected {
                self.isSelected = false
                return false
            } else {
                self.isSelected = true
                return true
            }
        }
}

extension Double {
    func roundTo(decimals: Int) -> Double {
        let divisor = pow(10.0, Double(decimals))
        return (self * divisor).rounded() / divisor
    }
}
