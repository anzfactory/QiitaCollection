//
//  UserListTableViewCell.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/03/01.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class UserListTableViewCell: UITableViewCell {

    // NARK: UI
    @IBOutlet weak var thumb: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var countPostItems: UILabel!
    @IBOutlet weak var countFollowing: UILabel!
    @IBOutlet weak var countFollower: UILabel!
    @IBOutlet weak var labelPostImtes: UILabel!
    @IBOutlet weak var labelFollowing: UILabel!
    @IBOutlet weak var labelFollower: UILabel!

    // MARK: ライフサイクル
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.thumb.backgroundColor = UIColor.backgroundDefaultImage()
        self.name.textColor = UIColor.textBase()
        self.countPostItems.textColor = UIColor.textBase()
        self.countFollowing.textColor = UIColor.textBase()
        self.countFollower.textColor = UIColor.textBase()
        self.labelPostImtes.textColor = UIColor.textBase()
        self.labelFollowing.textColor = UIColor.textBase()
        self.labelFollower.textColor = UIColor.textBase()
        
        self.prepare()
    }
    
    override func prepareForReuse() {
        self.prepare()
    }

    // MARK: メソッド
    func prepare() {
        self.thumb.image = nil
        self.name.text = ""
        self.countPostItems.text = "0"
        self.countFollowing.text = "0"
        self.countFollower.text = "0"
    }
    
    func showUser(user: UserEntity) {
        user.loadThumb(self.thumb)
        self.name.text = user.displayName
        self.countPostItems.text = String(user.itemCount)
        self.countFollower.text = String(user.followersCount)
        self.countFollowing.text = String(user.followeesCount)
    }
}
