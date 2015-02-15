//
//  UILabel+App.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/15.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

extension UILabel {
    func calcAdjustHeight(maxHeight: CGFloat) -> CGFloat {
        let maxTitleSize: CGSize = CGSize(width: self.bounds.size.width, height: maxHeight)
        let options = unsafeBitCast(NSStringDrawingOptions.UsesLineFragmentOrigin.rawValue | NSStringDrawingOptions.UsesFontLeading.rawValue,NSStringDrawingOptions.self)
        let actualSize: CGSize = NSString(string: self.text!).boundingRectWithSize(CGSize(width: maxTitleSize.width, height: maxTitleSize.height),
            options: options,
            attributes: [NSFontAttributeName: self.font],
            context: nil).size
        return actualSize.height
    }
}
