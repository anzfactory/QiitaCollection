//
//  KimonoEntity.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/07/06.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import SwiftyJSON
import Parse

struct KimonoEntity: EntityProtocol {
    
    let objectId: String
    let title: String
    let year: Int
    
    init(data: JSON) {
        self.objectId = ""
        self.title = ""
        self.year = 0
    }
    
    init(object: PFObject) {
        self.objectId = object.objectId!
        self.title = object["title"] as! String
        self.year = object["year"] as! Int
    }
    
}
