//
//  CommentEntity.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/28.
//  Copyright (c) 2015年 anz. All rights reserved.
//


import SwiftyJSON

struct CommentEntity: EntityProtocol {

    let id: String
    let body: String
    let htmlBody: String
    let updated: String
    let postUser: UserEntity
    
    init(data: JSON) {
        id = data["id"].string!
        body = data["body"].string!
        htmlBody = data["rendered_body"].string!
        updated = data["updated_at"].string!
        postUser = UserEntity(data: data["user"])
    }
    
    var shortUpdateDate: String {
        get { return updated.componentsSeparatedByString("T")[0] }
    }
    
    func canEdit() -> Bool {
        // 認証済みでかつ認証ユーザーがコメント投稿ユーザーの場合
        // 記事事態の所有者なら、他人のコメントも消せるかとおもったけどwebでは無理っぽいので
        // とりあえず認証ユーザー＝投稿ユーザーだけで
        return (UserDataManager.sharedInstance.isAuthorizedQiita() && self.postUser.id == UserDataManager.sharedInstance.qiitaAuthenticatedUserID)
    }
}