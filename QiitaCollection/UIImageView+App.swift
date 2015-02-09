//
//  UIImageView+App.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/08.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func setBlurView() {
        let effect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurView: UIVisualEffectView = UIVisualEffectView(effect: effect)
        self.addSubview(blurView)
        blurView.addConstraintFill()
    }
}