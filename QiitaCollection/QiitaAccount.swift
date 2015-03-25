//
//  QiitaAccount.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/03/23.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class QiitaAccount: AnonymousAccount {
   
    private(set) var qiitaId: String = "";
    
    convenience init(qiitaId: String) {
        self.init()
        self.qiitaId = qiitaId
    }
    
    override func signin(code: String, completion: (qiitaAccount: QiitaAccount) -> Void) {
        completion(qiitaAccount: self);
    }
    
    override func signout(completion: (anonymous: AnonymousAccount?) -> Void) {
        self.qiitaApiManager.deleteAccessToken(UserDataManager.sharedInstance.qiitaAccessToken, completion: { (isError) -> Void in
            
            if isError {
                completion(anonymous: nil)
                return
            }
            
            self.qiitaApiManager.clearHeader()
            UserDataManager.sharedInstance.clearQiitaAccessToken()
            
            let anonymus: AnonymousAccount = AnonymousAccount()
            completion(anonymous: anonymus)
            
        })
    }
    
    func follow(userId: String) {
        
    }
    
    func cancelFollow(userId: String) {
        
    }
    
    func comment(entryId: String) {
        
    }
    
    func deleteComment(commentId: String) {
        
    }
    
    func stock(entryId: String) {
        
    }
    
    func cancelStrock(entryId: String) {
        
    }
}
