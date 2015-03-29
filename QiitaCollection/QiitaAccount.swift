//
//  QiitaAccount.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/03/23.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class QiitaAccount: OtherAccount {
    
    private var qiitaId: String = "";
    
    override init() {
        super.init()
        self.qiitaId = userDataManager.qiitaAuthenticatedUserID
        if self.qiitaId.isEmpty {
            fatalError("not authorized user...")
        }
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
    
    func isSelf(userId: String) -> Bool {
        return self.qiitaId == userId
    }
    
    override func sync(completion: (user: UserEntity?) -> Void) {
        self.qiitaApiManager.getAuthenticatedUser({ (item, isError) -> Void in
            
            if item != nil {
                self.userDataManager.qiitaAuthenticatedUserID = item!.id
            }
            
            completion(user: item)
            
            return
        })
    }
    
    func entries(page:Int, completion: (total: Int, entries: [EntryEntity]) -> Void) {
        self.qiitaApiManager.getAuthenticatedUserItems(page, completion: { (total, items, isError) -> Void in
            if isError {
                completion(total: total, entries: [EntryEntity]())
                return
            }
            completion(total: total, entries: items)
        })
    }
    
    func isFollowed(userId: String, completion: (followed: Bool) -> Void ) {
        self.qiitaApiManager.getUserFollowing(userId, completion: completion)
    }
    
    func follow(userId: String, completion: (isError: Bool) -> Void) {
        self.qiitaApiManager.putUserFollowing(userId, completion: completion)
    }
    
    func cancelFollow(userId: String, completion: (isError: Bool) -> Void) {
        self.qiitaApiManager.deleteUserFollowing(userId, completion: completion)
    }
    
    func canFollow(userId: String) -> Bool {
        return self.qiitaId != userId
    }
    
    func canCommentEdit(authorId: String) -> Bool {
        // 認証済みでかつ認証ユーザーがコメント投稿ユーザーの場合
        // 記事事態の所有者なら、他人のコメントも消せるかとおもったけどwebでは無理っぽいので
        // とりあえず認証ユーザー＝投稿ユーザーだけで
        return authorId == self.qiitaId
    }
    
    func comment(entryId:String, text: String, completion: (isError: Bool) -> Void) {
        self.qiitaApiManager.postComment(entryId, body: text, completion: completion)
    }
    
    func commentEdit(commentId: String, text: String, completion:(isError: Bool) -> Void) {
        self.qiitaApiManager.patchComment(commentId, body: text, completion: completion)
    }
    
    func deleteComment(commentId: String, completion: (isError: Bool) -> Void) {
        self.qiitaApiManager.deleteComment(commentId, completion: completion)
    }
    
    func isStocked(entryId: String, completion: (stocked: Bool) -> Void) {
        self.qiitaApiManager.getItemStock(entryId, completion: completion)
    }
    
    func stock(entryId:String, completion: (isError: Bool) -> Void) {
        QiitaApiManager.sharedInstance.putItemStock(entryId, completion: completion)
    }
    
    func cancelStock(entryId: String, completion: (isError: Bool) -> Void) {
        self.qiitaApiManager.deleteItemStock(entryId, completion: completion)
    }
}
