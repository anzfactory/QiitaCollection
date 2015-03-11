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
    class func backgroundAccent() -> UIColor {
        return backgroundAccent(1)
    }
    class func backgroundAccent(a: CGFloat) -> UIColor {
        return factory(51, g: 122, b: 183, a: a)
    }
    class func backgroundSub() -> UIColor {
        return backgroundSub(1.0)
    }
    class func backgroundSub(a: CGFloat) -> UIColor {
        return factory(243, g: 246, b: 241, a: a)
    }
    class func attintion() -> UIColor {
        return factory(240, g: 173, b: 78, a: 1)
    }
    
    // MARK: 各種
    
    class func backgroundDefaultImage() -> UIColor {
        return factory(0, g:0, b:0, a:1);
    }
    class func backgroundNavigationBar() -> UIColor {
        return backgroundBase();
    }
    class func backgroundUserInfo() -> UIColor {
        return backgroundSub()
    }
    class func backgroundNavigationMenu() -> UIColor {
        return factory(119, g: 184, b: 66, a: 0.9)
    }
    class func backgroundSwipeCellDelete() -> UIColor {
        return UIColor.redColor()
    }
    class func backgroundSwipeCellEdit() -> UIColor {
        return backgroundAccent()
    }
    class func backgroundSearchCondition() -> UIColor {
        return backgroundSub()
    }
    class func backgroundPagerTab() -> UIColor {
        return backgroundSub()
    }
    class func backgroundComment() -> UIColor {
        return backgroundSub()
    }
    
    class func textNavigationBar() -> UIColor {
        return UIColor.whiteColor()
    }
    class func textPageMenuLabel() -> UIColor {
        return backgroundBase()
    }
    class func textBase() -> UIColor {
        return UIColor.darkGrayColor()
    }
    class func textLight() -> UIColor {
        return UIColor.whiteColor()
    }
    
    class func borderImageViewCircle() -> UIColor {
        return backgroundBase()
    }
    class func borderPageMenuIndicator() -> UIColor {
        return backgroundAccent()
    }
    class func borderNavigationMenuSeparator() -> UIColor {
        return backgroundBase();
    }
    class func borderTableView() -> UIColor {
        return backgroundBase()
    }
    class func borderButton() -> UIColor {
        return backgroundBase()
    }
    
    class func tintSegmented() -> UIColor {
        return self.backgroundBase()
    }
    class func tintAttention() -> UIColor {
        return attintion()
    }
    class func tintSelectedBarButton() -> UIColor {
        return backgroundAccent()
    }
    class func tintSelectedFollowingBarButton() -> UIColor {
        return factory(255, g: 85, b: 170, a: 1)
    }
    
    class func factory(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) -> UIColor {
        return UIColor(red: r/255, green: g/255, blue: b/255, alpha: a);
    }
    
}