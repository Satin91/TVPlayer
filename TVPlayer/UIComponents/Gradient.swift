//
//  Blur.swift
//  TVPlayer
//
//  Created by Артур Кулик on 08.01.2024.
//

import UIKit
import Accelerate

extension UIView {
    func gradient(start: CGFloat, end: CGFloat) {
        let gradient = CAGradientLayer()
        gradient.type = .axial
        gradient.colors = [
            UIColor.black.cgColor,
            UIColor.clear.cgColor,
        ]
        gradient.startPoint = CGPoint(x: 0.5, y: start)
        gradient.endPoint = CGPoint(x: 0.5, y: end)
        gradient.frame = bounds
        
        guard let sublayers = layer.sublayers else {
            layer.insertSublayer(gradient, at: 0)
            return
        }
        
        for (index, sublayer) in sublayers.enumerated() {
            if sublayer is CAGradientLayer {
                self.layer.sublayers?[index].removeFromSuperlayer()
            }
        }
        self.layer.insertSublayer(gradient, at: 0)
    }
}
