//
//  SearchTableViewCell.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/22.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class SearchTableViewCell: SWTableViewCell {

    // MARK: UI
    @IBOutlet weak var searchTypeLabel: UILabel!
    @IBOutlet weak var queryLabel: UILabel!
    @IBOutlet weak var matchingLabel: UILabel!
    
    // MARK: ライフサイクル
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let buttons: NSMutableArray = NSMutableArray()
        buttons.sw_addUtilityButtonWithColor(UIColor.backgroundSwipeCellDelete(), icon: UIImage(named: "icon_trash_white"))
        self.setRightUtilityButtons(buttons as [AnyObject], withButtonWidth: 60)
        
        self.prepare()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.prepare()

        if !self.isUtilityButtonsHidden() {
            self.hideUtilityButtonsAnimated(false)
        }
    }
    
    // MARK: メソッド
    func prepare() {
        self.searchTypeLabel.text = ""
        self.queryLabel.text = ""
        self.matchingLabel.text = ""
    }
    
    func show(item: SearchViewController.SearchConditionItem) {
        self.searchTypeLabel.text = item.type.name()
        self.queryLabel.text = item.query
        
        if item.isExclude {
            self.matchingLabel.text = "除外したもの"
        } else {
            self.matchingLabel.text = "該当するもの"
        }
    }

}
