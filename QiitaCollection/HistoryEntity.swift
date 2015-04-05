//
//  HistoryEntity.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/04/05.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import SwiftyJSON

struct HistoryEntity: EntityProtocol {
    
    let entryId: String
    let title: String
    let tags: [String]
    
    init(data: JSON) {
        self.entryId = data["entryId"].string!
        self.title = data["title"].string!
        
        var tags = [String]()
        for item in data["tags"].array! {
            tags.append(item.string!)
        }
        self.tags = tags
    }
    
    init(entryId: String, title: String, tags: [String]) {
        self.entryId = entryId
        self.title = title
        self.tags = tags
    }
    
}
