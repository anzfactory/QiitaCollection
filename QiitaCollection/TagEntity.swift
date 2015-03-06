//
//  TagEntity.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/08.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import SwiftyJSON

struct TagEntity: EntityProtocol {
    
    let id: String
    var version: String
    var iconUrl: String
    var itemsCount: Int
    var followerCount: Int
    
    init (data: JSON) {
        if let item = data["id"].string {
            id = item
        } else {
            id = data["name"].string!
        }
        version = data["version"].string ?? ""
        iconUrl = data["icon_url"].string ?? ""
        itemsCount = data["items_count"].intValue ?? 0
        followerCount = data["followers_count"].intValue ?? 0
    }
    
    mutating func loadThumb(imageView: UIImageView) {
        
        // icon urlが設定されていなければ、タグapi叩いて取ってくる
        if (self.iconUrl.isEmpty) {
            self.updateDetail({ (isError) -> Void in
                if isError || self.iconUrl.isEmpty {
                    return
                }
                self.loadThumb(imageView)
            })
        }

        let url: NSURL = NSURL(string: self.iconUrl)!
        imageView.sd_setImageWithURL(url, completed: { (image, error, cacheType, url) -> Void in
            if error != nil {
                // TODO: タグのデフォ画像
//                imageView.image = UIImage(named: "default")
                println("error..." + error.localizedDescription)
            }
        })
        
    }
    
    mutating func updateDetail(completion:(isError: Bool) -> Void) {
        let qiitaApi: QiitaApiManager = QiitaApiManager.sharedInstance
        let capture: TagEntity = self
        qiitaApi.getTag(self.id, completion: { (item, isError) -> Void in
            
            if isError {
                completion(isError: true)
                return
            }
            
            self.patchEntity(item!)
            completion(isError: false)
            
        })

        
    }
    
    mutating func patchEntity(tag: TagEntity) {
        self.version = tag.version
        self.iconUrl = tag.iconUrl
        self.itemsCount = tag.itemsCount
        self.followerCount = tag.followerCount
        
    }
}
