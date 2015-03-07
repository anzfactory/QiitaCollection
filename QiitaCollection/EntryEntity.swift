//
//  EntryEntity.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/07.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import SwiftyJSON

struct EntryEntity: EntityProtocol {
    
    let id: String
    let title: String
    let body: String
    let htmlBody: String
    let urlString: String
    let updateDate: String
    let postUser: UserEntity
    var tags: [TagEntity]
    
    init (data: JSON) {
        
        id = data["id"].string!
        title = data["title"].string!
        body = data["body"].string!
        htmlBody = data["rendered_body"].string!
        urlString = data["url"].string!
        updateDate = data["updated_at"].string!
        
        tags = [TagEntity]()
        for tagObject: JSON in data["tags"].array! {
            let tag: TagEntity = TagEntity(data: tagObject)
            tags.append(tag)
        }
        
        postUser = UserEntity(data: data["user"].dictionary!)
        
    }
    
    var shortUpdateDate: String {
        get { return updateDate.componentsSeparatedByString("T")[0] }
    }
    
    var beginning: String {
        get {
            let str: NSString = NSString(string: body)
            let result = body.substringToIndex(advance(body.startIndex, min(50, str.length)))
            return body.substringToIndex(advance(body.startIndex, min(50, str.length)))
                .stringByReplacingOccurrencesOfString("\n", withString: " ", options: nil, range: nil) + "…"
        }
    }
    
    func isStock(completion:(isStocked: Bool) -> Void) {
        QiitaApiManager.sharedInstance.getItemStock(self.id, completion: completion)
    }
    
    func stock(completion: (isError: Bool) -> Void) {
        QiitaApiManager.sharedInstance.putItemStock(self.id, completion: completion)
    }
    
    func cancelStock(completion: (isError: Bool) -> Void) {
        QiitaApiManager.sharedInstance.deleteItemStock(self.id, completion: completion)
    }
    
}
