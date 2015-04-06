//
//  EntryTableViewCell.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/15.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class EntryTableViewCell: UITableViewCell {

    // MARK: UI
    @IBOutlet weak var mainTag: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var date: UILabel!
    
    // MARK: プロパティ
    let maxHeightTitle: CGFloat = 38
    let dateFormatter: NSDateFormatter = NSDateFormatter()
    
    // MARK: ライフサイクル
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.mainTag.backgroundColor = UIColor.backgroundDefaultImage()
        self.title.textColor = UIColor.textBase()
        self.date.textColor = UIColor.textBase()
        
        self.dateFormatter.locale = NSLocale(localeIdentifier: "updatedAt")
        self.dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        self.prepare()

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.prepare()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: メソッド
    func prepare() {
        self.title.text = ""
        self.date.text = ""
    }
    
    func showEntry(entry: EntryEntity) {
        var mainTag: TagEntity = entry.tags[0]
        mainTag.loadThumb(self.mainTag)
        self.title.text = entry.title
//        self.title.sizeToFit()
        self.date.text = entry.shortUpdateDate
    }
    
    func showHistory(history: HistoryEntity) {
        var mainTag: TagEntity = TagEntity(tagId: history.tags[0])
        mainTag.loadThumb(self.mainTag)
        self.title.text = history.title
//        self.title.sizeToFit()
        self.date.text = self.dateFormatter.stringFromDate(history.updated)
    }

}
