//
//  CommentTableViewCell.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/28.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {
    
    typealias TapAction = (CommentTableViewCell) -> Void
    
    // MARK: UI
    @IBOutlet weak var bodyContent: UIView!
    @IBOutlet weak var thumb: UIButton!
    @IBOutlet weak var postDate: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var body: UILabel!
    @IBOutlet weak var edit: UIButton!
    
    // MARK: プロパティ
    var action: TapAction?
    var editCommentAction: TapAction?
    var account: AnonymousAccount? = nil

    // MARK: ライフサイクル
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.thumb.backgroundColor = UIColor.backgroundDefaultImage()
        self.thumb.maskCircle(UIColor.borderImageViewCircle(), lineWidth: 3.0)
        
        self.postDate.backgroundColor = UIColor.backgroundBase()
        self.postDate.textColor = UIColor.textLight()
        self.postDate.drawBorder(UIColor.backgroundBase(), linewidth: 1.0)
        
        self.bodyContent.backgroundColor = UIColor.backgroundComment()
        self.bodyContent.drawBorder(UIColor.backgroundBase(), linewidth: 2.0)
        
        self.edit.backgroundColor = UIColor.attintion()
        self.edit.maskCircle(UIColor.borderImageViewCircle(), lineWidth: 3.0)
        
    }

    func showComment(comment: CommentEntity) {
        
        comment.postUser.loadThumb(self.thumb)
        self.name.text = comment.postUser.displayName
        self.postDate.text = comment.shortUpdateDate
        var error: NSError? = nil
        self.body.attributedText = NSAttributedString(data: comment.htmlBody.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType], documentAttributes: nil, error: &error)
        
        if let qiitaAccount = self.account as? QiitaAccount {
            self.edit.hidden = !qiitaAccount.canCommentEdit(comment.postUser.id)
        } else {
            self.edit.hidden = true
        }
        
    }

    // MARK: Actions
    @IBAction func tapThumb(sender: AnyObject) {
        self.action?(self)
    }
    
    @IBAction func tapEdit(sender: AnyObject) {
        self.editCommentAction?(self)
    }
}
