//
//  RankEntity.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/05/19.
//  Copyright (c) 2015年 anz. All rights reserved.
//
import SwiftyJSON
import Parse

struct RankEntity: EntityProtocol {
    
    let rank: Int
    let entryId: String
    let title: String
    let author: String
    let stockNum: Int
    let tags: [String]
    let isNew: Bool
    
    init(data: JSON) {
        self.rank = 0
        self.entryId = ""
        self.title = ""
        self.author = ""
        self.stockNum = 0
        self.tags = [String]()
        self.isNew = false
    }
    
    init(object: PFObject) {
        self.rank = object["rank"] as! Int
        self.entryId = object["entryId"] as! String
        self.title = object["title"] as! String
        self.author = object["author"] as! String
        self.stockNum = object["stockNum"] as! Int
        self.tags = object["tags"] as? [String] ?? [String]()
        self.isNew = object["isNew"] as! Bool
    }
    
    func authorName() -> String {
        
        if self.author.isEmpty {
            return "Unknown"
        }
        return "@" + self.author
    }
    
}
