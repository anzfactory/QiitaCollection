//
//  Entry.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/03/29.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class Entry: NSObject {
    
    private(set) var entryId: String = ""
    let qiitaApiManager = QiitaApiManager()
    
    override init() {
        super.init()
        self.entryId = ""
    }
    
    convenience init(entryId: String) {
        self.init()
        self.entryId = entryId
    }
    
    func stockers(page:Int, completion: (total:Int, users:[UserEntity]) -> Void) {
        
        if self.entryId.isEmpty {
            completion(total: 0, users: [UserEntity]())
            return
        }
        
        self.qiitaApiManager.getStockers(self.entryId, page: page) { (total, items, isError) -> Void in
            if isError {
                completion(total: total, users: [UserEntity]())
                return
            }
            completion(total: total, users: items)
        }
    }
   
}
