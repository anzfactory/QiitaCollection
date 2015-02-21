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
    @IBOutlet weak var introduction: UILabel!
    @IBOutlet weak var website: UIButton!
    @IBOutlet weak var github: UIButton!
    @IBOutlet weak var twitter: UIButton!
    @IBOutlet weak var facebook: UIButton!
    @IBOutlet weak var linkedin: UIButton!
    @IBOutlet weak var attention: UIButton!
    
    // MARK: 制約
    @IBOutlet weak var constraintIntroductionHeight: NSLayoutConstraint!
    
    // MARK: プロパティ
    weak var delegate: UserDetailViewDelegate?
    
    override func awakeFromNib() {
        self.backgroundColor = UIColor.backgroundUserInfo()
        
        self.profImage.backgroundColor = UIColor.backgroundBase()

        self.userId.text = ""
        self.name.text = ""
        self.introduction.text = ""
        
        self.attention.setImage(self.attention.imageView?.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
    }
    
    func showUser(info: UserEntity) {
        
        info.loadThumb(self.profImage)
        self.userId.text = info.id
        self.name.text = info.name
        self.introduction.text = info.introduction
        self.constraintIntroductionHeight.constant = self.introduction.calcAdjustHeight(self.constraintIntroductionHeight.constant)
        
        self.website.enabled = !info.web.isEmpty
        self.github.enabled = !info.github.isEmpty
        self.twitter.enabled = !info.twitter.isEmpty
        self.facebook.enabled = !info.facebook.isEmpty
        self.linkedin.enabled = !info.linkedin.isEmpty
        self.attention.hidden = UserDataManager.sharedInstance.isMutedUser(info.id)
    }
    
    @IBAction func tap(sender: UIButton) {
        self.delegate?.userDetailView(self, sender: sender)
    }
    
}
