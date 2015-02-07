//
//  EntryEntity.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/07.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import SwiftyJSON

struct EntryEntity {
    
    let id: String;
    let title: String;
    let body: String;
    let htmlBody: String;
    let urlString: String;
    
    init (data: JSON) {
        id = data["id"].string!;
        title = data["title"].string!;
        body = data["body"].string!;
        htmlBody = data["rendered_body"].string!;
        urlString = data["url"].string!;
        
        // TOOD Tags
        
        // TODO 投稿者
    }
    
}
