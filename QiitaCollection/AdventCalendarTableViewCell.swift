//
//  AdventCalendarTableViewCell.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/07/06.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class AdventCalendarTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var day: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.dateLabel.textColor = UIColor.textAdventCalendar()
        self.dateLabel.backgroundColor = UIColor.backgroundSub()
        self.dateLabel.drawBorder(UIColor.borderImageViewCircle(), linewidth: 1)
        self.day.textColor = UIColor.textAdventCalendar()
        self.title.textColor = UIColor.textBase()
        self.authorLabel.textColor = UIColor.textBase()

        self.prepare()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.prepare()
    }
    
    private func prepare() {
        self.dateLabel.text = ""
        self.title.text = ""
        self.authorLabel.text = ""
    }
    
    func show(entity: AdventEntity) {
        self.dateLabel.text = String(entity.date)
        self.title.text = entity.displayTitle()
        self.authorLabel.text = entity.displayAuthor()
    }


}
