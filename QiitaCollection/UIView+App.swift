//
//  UIView+App.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/09.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

extension UIView {
    
    func maskCircle(borderColor: UIColor?) {
        self.maskCircle(borderColor, lineWidth: 1.0)
    }
    
    func maskCircle(borderColor: UIColor?, lineWidth: CGFloat) {
        let circle: CAShapeLayer = CAShapeLayer()
        let circlePath: UIBezierPath = UIBezierPath(ovalInRect: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        circle.path = circlePath.CGPath
        circle.fillColor = UIColor.backgroundDefaultImage().CGColor
        circle.lineWidth = 0.0
        self.layer.mask = circle
        
        if let color = borderColor {
            let border: CAShapeLayer = CAShapeLayer()
            border.path = circlePath.CGPath
            border.fillColor = UIColor.clearColor().CGColor
            border.lineWidth = lineWidth
            border.strokeColor = color.CGColor
            
            if let views = self.layer.sublayers {
                if !views.isEmpty {
                    for layer: CALayer in views.reverse() as [CALayer] {
                        layer.removeFromSuperlayer()
                    }
                }
            }
            self.layer.addSublayer(border)
        }
    }
}