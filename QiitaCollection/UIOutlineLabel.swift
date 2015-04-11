//
//  UIOutlineLabel.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/04/11.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class UIOutlineLabel: UILabel {
    
    var outlineSize: CGFloat = 1.5

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    override func drawTextInRect(rect: CGRect) {
        // 縁取り描画
        let cr: CGContextRef = UIGraphicsGetCurrentContext()
        let textColor: UIColor = self.textColor
        
        CGContextSetLineWidth(cr, self.outlineSize)
        CGContextSetLineJoin(cr, kCGLineJoinRound)
        CGContextSetTextDrawingMode(cr, kCGTextStroke)
        self.textColor = UIColor.textShadow()
        super.drawTextInRect(rect)
        
        CGContextSetTextDrawingMode(cr, kCGTextFill)
        self.textColor = textColor
        super.drawTextInRect(rect)
    }
}
