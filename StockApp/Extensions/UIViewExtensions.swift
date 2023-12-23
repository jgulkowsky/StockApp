//
//  UIViewExtensions.swift
//  StockApp
//
//  Created by Jan Gulkowski on 22/12/2023.
//

import UIKit

extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.45
        animation.values = [-9.0, 9.0, -4.0, 4.0, -1.0, 1.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
}
