//
//  HistoryEntity.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/04/05.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import SwiftyJSON
import Parse

struct HistoryEntity: EntityProtocol {
    
    let entryId: String
    let title: String
    let tags: [String]
    let updated: NSDate
    
    init(data: JSON) {
        self.entryId = data["entryId"].string!
        self.title = data["title"].string!
        
        var tags = [String]()
        for item in data["tags"].array! {
            tags.append(item.string!)
        }
        self.tags = tags
        
        self.updated = NSDate()
    }
    
    init(object: PFObject) {
        self.entryId = object["entryId"] as String
        self.title = object["title"] as String
        self.tags = object["tags"] as [String]
        self.updated = object.updatedAt
    }
    
}
