//
//  SlideTableViewCell.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/21.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class SlideTableViewCell: SWTableViewCell {
    
    var isReused: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
      
        self.textLabel?.textColor = UIColor.textBase()
        // MEMO: パターンが増えてきたら場合分け
        var buttons: NSMutableArray = NSMutableArray()
        buttons.sw_addUtilityButtonWithColor(UIColor.backgroundSwipeCellDelete(), icon: UIImage(named: "icon_trash_white"))
        self.setRightUtilityButtons(buttons, withButtonWidth: 60)
        
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        isReused = true
        self.hideUtilityButtonsAnimated(false)
        
    }
}
