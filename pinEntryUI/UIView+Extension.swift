//
//  UIView+Extension.swift
//  pinEntryUI
//
//  Created by Dave Johnson on 1/16/18.
//  Copyright © 2018 Paycom. All rights reserved.
//

import UIKit

extension UIView {
    
    // Shake Screen View
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
}
