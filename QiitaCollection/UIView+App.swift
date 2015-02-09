//
//  UIView+App.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/09.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

extension UIView {
    
    func maskCircle(borderColor: UIColor) {
        let layerRect: CGRect = CGRectMake(0, 0, self.layer.frame.size.width, self.layer.frame.size.width)
        let mask: CAShapeLayer = CAShapeLayer()
        let maskPath: UIBezierPath = UIBezierPath(ovalInRect: layerRect)
        mask.path = maskPath.CGPath
        mask.fillColor = UIColor.backgroundDefaultImage().CGColor
        mask.lineWidth = 0.0
        self.layer.mask = mask;
        
        let border: CAShapeLayer = CAShapeLayer()
        let borderPath: UIBezierPath = UIBezierPath(ovalInRect: layerRect)
        border.path = borderPath.CGPath
        border.fillColor = UIColor.clearColor().CGColor
        border.lineWidth = 2.0
        border.strokeColor = borderColor.CGColor
        
        if (self.layer.sublayers?.isEmpty != nil) {
            for l:CALayer in self.layer.sublayers?.reverse() as [CALayer] {
                l.removeFromSuperlayer()
            }
        }
        self.layer.addSublayer(border)
    }
}