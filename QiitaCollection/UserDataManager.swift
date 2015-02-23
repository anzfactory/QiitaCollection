//
//  UserDataManager.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/21.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import Foundation

class UserDataManager {
    
    // シングルトンパターン
    class var sharedInstance : UserDataManager {
        struct Static {
            static let instance : UserDataManager = UserDataManager()
        }
        return Static.instance
    }
    
    // MARK: プロパティ
    let ud : NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    enum UDKeys: String {
        case
        MuteUsers = "ud-key-mute-users",
        Queries = "ud-key-queries"
    }
    
    // ミュートユーザーのID
    var muteUsers: [String] = [String]()
    // 保存した検索クエリ
    var queries: [String: String] = [String: String]()
    
    // MARK: ライフサイクル
    init() {
        let defaults: [String: AnyObject] = [
            UDKeys.MuteUsers.rawValue: [String](),
            UDKeys.Queries.rawValue  : [String: String]()
        ]
        self.ud.registerDefaults(defaults)
        self.muteUsers = self.ud.arrayForKey(UDKeys.MuteUsers.rawValue) as [String]
        self.queries = self.ud.dictionaryForKey(UDKeys.Queries.rawValue) as [String: String]
    }
    
    // MARK: メソッド
    func saveAll() {
        
        // プロパティで保持していたのをudへ書き込む
        self.ud.setObject(self.muteUsers, forKey: UDKeys.MuteUsers.rawValue)
        self.ud.setObject(self.queries, forKey: UDKeys.Queries.rawValue)
        self.ud.synchronize()
    }
    
    func appendMuteUserId(userId: String) -> Bool {
        if self.isMutedUser(userId) {
            return false
        }
        
        self.muteUsers.append(userId)
        return true
    }
    
    func isMutedUser(userId: String) -> Bool {
        return contains(self.muteUsers, userId)
    }
    
    func clearMutedUser(userId: String) -> [String] {
        if !isMutedUser(userId) {
            return self.muteUsers
        }
        
        self.muteUsers.removeObject(userId)
        
        return self.muteUsers
    }
    
    func appendQuery(query: String, label: String) {
        self.queries[query] = label
    }
    
    
}
