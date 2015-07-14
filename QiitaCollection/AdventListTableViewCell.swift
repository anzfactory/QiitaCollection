//
//  AdventListTableViewCell.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/07/06.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class AdventListTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.title.textColor = UIColor.textBase()
        self.prepare()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.prepare()
    }

    // MARK: メソッド
    func prepare() {
        self.title.text = ""
    }
    
    func show(entity: KimonoEntity) {
        self.title.text = entity.title
    }
}
