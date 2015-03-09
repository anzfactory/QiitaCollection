//
//  EntryCollectionViewCell.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/07.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class EntryCollectionViewCell: UICollectionViewCell {
    
    // MARK: UI
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var postDate: UILabel!
    @IBOutlet weak var mainTag: UILabel!
    @IBOutlet weak var tagImage: UIImageView!
    @IBOutlet weak var iconStar: UIImageView!
    @IBOutlet weak var stockCount: UILabel!
    @IBOutlet weak var iconComment: UIImageView!
    @IBOutlet weak var commentCount: UILabel!
    
    // MARK: Constraint
    @IBOutlet weak var constraintDateWidth: NSLayoutConstraint!
    @IBOutlet weak var constraintStockWidth: NSLayoutConstraint!
    
    // MARK: ライフサイクル
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundImage.backgroundColor = UIColor.backgroundDefaultImage()
        self.backgroundImage.setBlurView()
        self.iconStar.image = self.iconStar.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        self.iconComment.image = self.iconComment.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        
        self.tagImage.backgroundColor = UIColor.backgroundDefaultImage()
        
        self.prepare()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // 各パーツの初期化
        self.prepare()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.tagImage.maskCircle(UIColor.borderImageViewCircle())
    }
    
    // MARK: メソッド
    func prepare() {
        self.title.text = ""
        self.postDate.text = ""
        self.mainTag.text = ""
        self.backgroundImage.image = UIImage(named: "default");
    }
    
    func display(entry: EntryEntity) {
        
        // 背景(プロフサムネ)
        entry.postUser.loadThumb(self.backgroundImage)
        
        // タグイメージ
        var tag: TagEntity = entry.tags[0]
        tag.loadThumb(self.tagImage)
        
        // title
        self.title.font = UIFont(name: "07LightNovelPOP", size: self.title.font.pointSize)
        self.title.text = entry.title
        self.title.frame.size.height = self.title.sizeThatFits(CGSize(width: self.bounds.width, height: self.bounds.height)).height
        // 著者
        self.author.text = entry.postUser.displayName
        // ストック
        self.stockCount.text = "99"  // TODO: ストック数
        self.stockCount.sizeToFit()
        self.constraintStockWidth.constant = self.stockCount.frame.size.width
        // コメント
        self.commentCount.text = "123"  // TODO: コメント数
        // main tag
        self.mainTag.text = entry.tags[0].id
        // 投稿日
        self.postDate.text = entry.shortUpdateDate
        self.postDate.sizeToFit()
        
    }
}
