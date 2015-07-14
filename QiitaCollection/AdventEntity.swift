//
//  AdventCalendar.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/07/06.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import SwiftyJSON
import Parse

struct AdventEntity: EntityProtocol {
    
    let date: Int
    let title: String
    let url: String
    let author: String
    let authorUrl: String
    
    init(data: JSON) {
        date = 0
        title = ""
        url = ""
        author = ""
        authorUrl = ""
    }
    
    init(object: PFObject) {
        self.title = object["title"] as! String
        self.date = object["date"] as! Int
        self.url = object["url"] as! String
        self.author = object["author"] as! String
        self.authorUrl = object["authorUrl"] as! String
    }
    
    func displayTitle() -> String {
        if url.isEmpty {
            return self.title + "（未記入）"
        } else {
            return self.title
        }
    }
    
    func displayAuthor() -> String {
        return "@" + author
    }
    
}

