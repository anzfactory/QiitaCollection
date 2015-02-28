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
        Queries = "ud-key-queries",
        Pins = "ud-key-pins",
        EntryFiles = "ud-key-entry-files"
    }
    
    // ミュートユーザーのID
    var muteUsers: [String] = [String]()
    // 保存した検索クエリ
    var queries: [String: String] = [String: String]()
    // クリップしたもの
    var pins: [[String: String]] = [[String: String]]()
    // 保存したもの
    var entryFiles: [[String: String]] = [[String: String]]()
    
    // MARK: ライフサイクル
    init() {
        var defaults = [
            UDKeys.MuteUsers.rawValue : self.muteUsers,
            UDKeys.Queries.rawValue   : self.queries,
            UDKeys.Pins.rawValue      : self.pins,
            UDKeys.EntryFiles.rawValue: self.entryFiles
        ]
        self.ud.registerDefaults(defaults)
        self.muteUsers = self.ud.arrayForKey(UDKeys.MuteUsers.rawValue) as [String]
        self.queries = self.ud.dictionaryForKey(UDKeys.Queries.rawValue) as [String: String]
        self.pins = self.ud.arrayForKey(UDKeys.Pins.rawValue) as [[String: String]]
        self.entryFiles = self.ud.arrayForKey(UDKeys.EntryFiles.rawValue) as [[String: String]]
    }
    
    // MARK: メソッド
    func saveAll() {
        
        // プロパティで保持していたのをudへ書き込む
        self.ud.setObject(self.muteUsers, forKey: UDKeys.MuteUsers.rawValue)
        self.ud.setObject(self.queries, forKey: UDKeys.Queries.rawValue)
        self.ud.setObject(self.pins, forKey: UDKeys.Pins.rawValue)
        self.ud.setObject(self.entryFiles, forKey: UDKeys.EntryFiles.rawValue)
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
    
    func appendPinEntry(entryId: String, entryTitle: String) {
        
        if self.pins.count >= 10 {
            self.pins.removeAtIndex(0)
        } else if self.hasPinEntry(entryId) != NSNotFound {
            // 重複ID
            return
        }
        
        self.pins.append([
            "id"   : entryId,
            "title": entryTitle
        ])
    }
    
    func hasPinEntry(entryId: String) -> Int {
        return self.indexItem(self.pins, target: entryId)
    }
    
    func clearPinEntry(index: Int) -> [[String: String]] {
        self.pins.removeAtIndex(index)
        return self.pins
    }
    func clearPinEntry(entryId: String) -> [[String: String]] {
        
        let index: Int = self.hasPinEntry(entryId)
        if index == NSNotFound {
            return self.pins
        }

        self.pins.removeAtIndex(index)
        
        return self.pins
    }
    
    
    func titleSavedEntry(entryId: String) -> String {
        let index: Int = self.indexItem(self.entryFiles, target: entryId)
        if index == NSNotFound {
            return ""
        }
        let item: [String: String] = self.entryFiles[index]
        return item["title"]!
    }
    func hasSavedEntry(entryId: String) -> Bool {
        return self.indexItem(self.entryFiles, target: entryId) != NSNotFound
    }
    func appendSavedEntry(entryId: String, title:String) {
        
        if self.hasSavedEntry(entryId) {
            return
        }
        
        self.entryFiles.append([
            "id"    : entryId,
            "title" : title
        ])
        
    }
    
    
    
    func indexItem(items: [[String: String]], target:String, id: String = "id") -> Int {
        for var i = 0; i < items.count; i++ {
            let item = items[i]
            if item[id] == target {
                return i
            }
        }
        return NSNotFound
    }
    
}
