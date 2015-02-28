//
//  CommentTableViewCell.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/28.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {
    
    typealias ThumbTapAction = (CommentTableViewCell) -> Void
    
    // MARK: UI
    @IBOutlet weak var bodyContent: UIView!
    @IBOutlet weak var thumb: UIButton!
    @IBOutlet weak var postDate: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var body: UILabel!
    
    // MARK: プロパティ
    var action: ThumbTapAction?

    // MARK: ライフサイクル
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.thumb.backgroundColor = UIColor.backgroundDefaultImage()
        self.thumb.maskCircle(UIColor.borderImageViewCircle(), lineWidth: 3.0)
        self.bodyContent.backgroundColor = UIColor.backgroundComment()
        self.bodyContent.layer.borderColor = UIColor.backgroundBase().CGColor
        self.bodyContent.layer.cornerRadius = 5.0
        self.bodyContent.layer.borderWidth = 2.0
        
    }

    func showComment(comment: CommentEntity) {
        
        comment.postUser.loadThumb(self.thumb)
        self.name.text = comment.postUser.displayName
        self.postDate.text = comment.shortUpdateDate
        var error: NSError? = nil
        self.body.attributedText = NSAttributedString(data: comment.htmlBody.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType], documentAttributes: nil, error: &error)
        
    }

    // MARK: Actions
    @IBAction func tapThumb(sender: AnyObject) {
        self.action?(self)
    }
}
