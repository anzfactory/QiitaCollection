//
//  UIColor+App.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/07.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit


extension UIColor {
    
    // MARK: 基幹色
    class func backgroundBase() -> UIColor {
        return factory(119, g: 184, b: 66, a: 1)
    }
    
    // MARK: 各種
    
    class func backgroundDefaultImage() -> UIColor {
        return factory(0, g:0, b:0, a:1);
    }
    class func backgroundNavigationBar() -> UIColor {
        return backgroundBase();
    }
    class func backgroundUserInfo() -> UIColor {
        return factory(243, g: 246, b: 241, a: 1)
    }
    class func backgroundNavigationMenu() -> UIColor {
        return factory(119, g: 184, b: 66, a: 0.9)
    }
    
    class func textNavigationBar() -> UIColor {
        return UIColor.whiteColor()
    }
    class func textPageMenuLabel() -> UIColor {
        return backgroundBase()
    }
    
    class func borderImageViewCircle() -> UIColor {
        return backgroundBase()
    }
    class func borderPageMenuIndicator() -> UIColor {
        return UIColor.orangeColor()
    }
    class func borderNavigationMenuSeparator() -> UIColor {
        return backgroundBase();
    }
    
    class func tintSegmented() -> UIColor {
        return self.backgroundBase()
    }
    
    class func factory(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) -> UIColor {
        return UIColor(red: r/255, green: g/255, blue: b/255, alpha: a);
    }
    
}