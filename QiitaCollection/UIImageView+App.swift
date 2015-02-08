//
//  UIImageView+App.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/08.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func maskCircle(borderColor: UIColor) {
        self.layer.cornerRadius = self.layer.frame.size.width / 2.0
        self.layer.masksToBounds = true
        self.layer.borderColor = borderColor.CGColor
        self.layer.borderWidth = 3.0
    }
    
    func setBlurView() {
        let effect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurView: UIVisualEffectView = UIVisualEffectView(effect: effect)
        self.addSubview(blurView)
        blurView.addConstraintFill()
    }
}