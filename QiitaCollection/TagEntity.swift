//
//  TagEntity.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/08.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import SwiftyJSON
import SDWebImage

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
    
    init (tagId: String) {
        self.id = tagId
        self.version = ""
        self.iconUrl = ""
        self.itemsCount = 0
        self.followerCount = 0
    }
    
    mutating func loadThumb(imageView: UIImageView) {
        
        // icon urlが設定されていなければ、タグapi叩いて取ってくる
        if (self.iconUrl.isEmpty) {
            self.updateDetail({ (isError, var entity) -> Void in
                if isError || entity!.iconUrl.isEmpty {
                    return
                }
                entity!.loadThumb(imageView)
            })
            return
        }

        let url: NSURL = NSURL(string: self.iconUrl)!
        imageView.sd_setImageWithURL(url, completed: { (image, error, cacheType, url) -> Void in
            if error != nil {
                imageView.image = UIImage(named: "default")
            }
        })
        
    }
    
    mutating func updateDetail(completion:(isError: Bool, entity: TagEntity?) -> Void) {
        let qiitaApi: QiitaApiManager = QiitaApiManager.sharedInstance
        qiitaApi.getTag(self.id, completion: { (item, isError) -> Void in
            
            if isError {
                completion(isError: true, entity:nil)
                return
            }
            
            self.patchEntity(item!)
            completion(isError: false, entity:self)
            
        })

        
    }
    
    mutating func patchEntity(tag: TagEntity) -> TagEntity {
        self.version = tag.version
        self.iconUrl = tag.iconUrl
        self.itemsCount = tag.itemsCount
        self.followerCount = tag.followerCount
        return self
    }
    
    static func titles(tags: [TagEntity]) -> [String] {
        var titles: [String] = [String]()
        for tag in tags {
            titles.append(tag.id)
        }
        return titles
    }
}
