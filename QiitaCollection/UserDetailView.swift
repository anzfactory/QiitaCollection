//
//  UserDetailView.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/15.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

protocol UserDetailViewDelegate: NSObjectProtocol {
    func userDetailView(view: UserDetailView, sender: UIButton) -> Void
}

class UserDetailView: UIView {
    // MARK: UI
    @IBOutlet weak var profImage: UIImageView!
    @IBOutlet weak var userId: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var introduction: UIButton!
    @IBOutlet weak var website: UIButton!
    @IBOutlet weak var github: UIButton!
    @IBOutlet weak var twitter: UIButton!
    @IBOutlet weak var facebook: UIButton!
    @IBOutlet weak var linkedin: UIButton!
    
    // MARK: 制約
    @IBOutlet weak var constraintIntroductionHeight: NSLayoutConstraint!
    
    // MARK: プロパティ
    weak var delegate: UserDetailViewDelegate?
    
    // MARK
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.backgroundUserInfo()
        
        self.profImage.backgroundColor = UIColor.backgroundBase()

        self.userId.textColor = UIColor.textBase()
        self.userId.text = ""
        self.name.textColor = UIColor.textBase()
        self.name.text = ""
        self.introduction.setTitleColor(UIColor.textBase(), forState: UIControlState.Normal)
        self.introduction.setTitle("", forState: UIControlState.Normal)
        self.introduction.titleLabel?.numberOfLines = 3
    }
    
    func showUser(info: UserEntity) {
        
        info.loadThumb(self.profImage)
        self.userId.text = info.id
        self.name.text = info.name
        self.introduction.setTitle(info.introduction, forState: UIControlState.Normal)
        
        self.website.enabled = !info.web.isEmpty
        self.github.enabled = !info.github.isEmpty
        self.twitter.enabled = !info.twitter.isEmpty
        self.facebook.enabled = !info.facebook.isEmpty
        self.linkedin.enabled = !info.linkedin.isEmpty

    }
    
    @IBAction func tap(sender: UIButton) {
        self.delegate?.userDetailView(self, sender: sender)
    }
    
    @IBAction func tapIntroduction(sneder: UIButton) {
        
        if self.introduction.titleLabel?.text?.isEmpty ?? true {
            return
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(
            QCKeys.Notification.ShowAlertOkOnly.rawValue,
            object: nil,
            userInfo: [
                QCKeys.AlertView.Message.rawValue: self.introduction.titleLabel?.text ?? "",
                QCKeys.AlertView.Title.rawValue  : "紹介文"
            ]
        )
    }
}
