//
//  OtherAccount.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/03/29.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class OtherAccount: AnonymousAccount {
   
    private var qiitaId: String = "";
    private(set) var entity: UserEntity? = nil {
        didSet {
            if let userEntity = self.entity {
                self.qiitaId = userEntity.id
            } else {
                self.qiitaId = ""
            }
        }
    };
    
    convenience init(qiitaId: String) {
        self.init()
        self.qiitaId = qiitaId
    }
    
    func sync(completion: (user: UserEntity?) -> Void) {
        self.qiitaApiManager.getUser(self.qiitaId, completion: { (item, isError) -> Void in
            self.entity = item!
            completion(user: item)
        })
    }
    
    func stockEntries(page:Int, entryId:String, completion:(total:Int, entries:[EntryEntity]) -> Void) {
        self.qiitaApiManager.getEntriesUserStocks(self.qiitaId, page: page) { (total, items, isError) -> Void in
            if isError {
                completion(total: total, entries: [EntryEntity]())
                return
            }
            completion(total: total, entries: items)
        }
    }
    
}
