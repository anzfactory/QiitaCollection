//
//  QCPathMenuItem.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/24.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class QCPathMenuItem: PathMenuItem {
    
    typealias TapAction = () -> Void
    
    // MARK: プロパティ
    var action: TapAction? = nil
    
    // MARK: イニシャライザ
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(mainImage: UIImage) {
        self.init(frame: CGRectZero)
        self.image = mainImage
        self.highlightedImage = mainImage
        self.userInteractionEnabled = true
        self.contentImageView = UIImageView(image: mainImage)
        self.contentImageView?.highlightedImage = mainImage
        self.addSubview(self.contentImageView!)
    }
    

}
