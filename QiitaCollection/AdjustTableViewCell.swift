//
//  AdjustTableViewCell.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/03/05.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class AdjustTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var constraintMarginRight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.title.textColor = UIColor.textBase()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.constraintMarginRight.constant = 8.0
        self.title.textAlignment = .Right
        self.title.font = UIFont.systemFontOfSize(14.0)
    }
}
