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
        EntryFiles = "ud-key-entry-files",
        DisplayedGuides = "ud-key-displayed-guide",
        QiitaAccessToken = "ud-key-qiita-access-token",
        QiitaAuthenticatedUserID = "ud-key-qiita-authenticated-user-id",
        GridCoverImage = "ud-key-grid-cover-image",
        ViewCoverImage = "ud-key-view-cover-image"
    }
    
    // ミュートユーザーのID
    var muteUsers: [String] = [String]()
    // 保存した検索クエリ
    var queries: [[String: String]] = [[String: String]]()
    // クリップしたもの
    var pins: [[String: String]] = [[String: String]]()
    // 保存したもの
    var entryFiles: [[String: String]] = [[String: String]]()
    // 表示したガイド
    var displayedGuides: [Int] = [Int]()
    // Qiita AccessToken
    var qiitaAccessToken: String = "" {
        didSet {
            if self.qiitaAccessToken.isEmpty {
                return
            }
            self.saveAuth() // 即時保存させる
        }
    }
    // Qiita AuthenticatedUser ID
    var qiitaAuthenticatedUserID: String = "" {
        didSet {
            if self.qiitaAuthenticatedUserID.isEmpty {
                return
            }
            self.saveAuth() // 即時保存させる
        }
    }
    var imageDataForGridCover: NSData? = nil
    var imageDataForViewCover: NSData? = nil
    
    // MARK: ライフサイクル
    init() {
        var defaults = [
            UDKeys.MuteUsers.rawValue               : self.muteUsers,
            UDKeys.Queries.rawValue                 : self.queries,
            UDKeys.Pins.rawValue                    : self.pins,
            UDKeys.EntryFiles.rawValue              : self.entryFiles,
            UDKeys.DisplayedGuides.rawValue         : self.displayedGuides,
            UDKeys.QiitaAccessToken.rawValue        : self.qiitaAccessToken,
            UDKeys.QiitaAuthenticatedUserID.rawValue: self.qiitaAuthenticatedUserID
        ]
        self.ud.registerDefaults(defaults as [NSObject : AnyObject])
        self.muteUsers = self.ud.arrayForKey(UDKeys.MuteUsers.rawValue) as! [String]
        self.queries = self.ud.arrayForKey(UDKeys.Queries.rawValue) as! [[String: String]]
        self.pins = self.ud.arrayForKey(UDKeys.Pins.rawValue) as! [[String: String]]
        self.entryFiles = self.ud.arrayForKey(UDKeys.EntryFiles.rawValue) as! [[String: String]]
        self.displayedGuides = self.ud.arrayForKey(UDKeys.DisplayedGuides.rawValue) as! [Int]
        self.qiitaAccessToken = self.ud.stringForKey(UDKeys.QiitaAccessToken.rawValue)!
        self.qiitaAuthenticatedUserID = self.ud.stringForKey(UDKeys.QiitaAuthenticatedUserID.rawValue)!
        self.imageDataForGridCover = self.ud.dataForKey(UDKeys.GridCoverImage.rawValue)
        self.imageDataForViewCover = self.ud.dataForKey(UDKeys.ViewCoverImage.rawValue)
    }
    
    // MARK: メソッド
    func saveAuth() {
        self.ud.setObject(self.qiitaAccessToken, forKey: UDKeys.QiitaAccessToken.rawValue)
        self.ud.setObject(self.qiitaAuthenticatedUserID, forKey: UDKeys.QiitaAuthenticatedUserID.rawValue)
        self.ud.synchronize()
    }
    func saveAll() {
        
        // プロパティで保持していたのをudへ書き込む
        self.ud.setObject(self.muteUsers, forKey: UDKeys.MuteUsers.rawValue)
        self.ud.setObject(self.queries, forKey: UDKeys.Queries.rawValue)
        self.ud.setObject(self.pins, forKey: UDKeys.Pins.rawValue)
        self.ud.setObject(self.entryFiles, forKey: UDKeys.EntryFiles.rawValue)
        self.ud.setObject(self.displayedGuides, forKey: UDKeys.DisplayedGuides.rawValue)
        self.ud.setObject(self.qiitaAccessToken, forKey: UDKeys.QiitaAccessToken.rawValue)
        self.ud.setObject(self.qiitaAuthenticatedUserID, forKey: UDKeys.QiitaAuthenticatedUserID.rawValue)
        self.ud.setObject(self.imageDataForGridCover, forKey: UDKeys.GridCoverImage.rawValue)
        self.ud.setObject(self.imageDataForViewCover, forKey: UDKeys.ViewCoverImage.rawValue)
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
        
        let index = self.indexItem(self.queries, target: query, id: "query")
        if index != NSNotFound {
            return
        }
        
        self.queries.append([
            "query": query,
            "title": label
        ])
    }
    func clearQuery(query: String) {
        let index = self.indexItem(self.queries, target: query, id: "query")
        if index == NSNotFound {
            return
        }
        
        self.queries.removeAtIndex(index)
    }
    func clearQuery(index: Int) {

        if index >= self.queries.count {
            return
        }
        
        self.queries.removeAtIndex(index)
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
    func removeEntry(entryId: String) {
        let index = self.indexItem(self.entryFiles, target: entryId)
        self.entryFiles.removeAtIndex(index)
    }
    
    
    func isDisplayedGuide(guide: Int) -> Bool {
        return contains(self.displayedGuides, guide)
    }
    func appendDisplayedGuide(guide: Int) {
        if self.isDisplayedGuide(guide) {
            return
        }
        self.displayedGuides.append(guide)
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
    
    
    func setQiitaAccessToken(token: String) {
        self.qiitaAccessToken = token
    }
    func clearQiitaAccessToken() {
        self.qiitaAccessToken = ""
    }
    func isAuthorizedQiita() -> Bool {
        return !self.qiitaAccessToken.isEmpty
    }
    
    func setImageForGridCover(image: UIImage) {
        self.imageDataForGridCover = UIImagePNGRepresentation(image)
        self.imageDataForViewCover = nil
    }
    func setImageForViewCover(image: UIImage) {
        self.imageDataForViewCover = UIImagePNGRepresentation(image)
        self.imageDataForGridCover = nil
    }
    func clearImageCover() {
        self.imageDataForViewCover = nil
        self.imageDataForGridCover = nil
    }
    func hasImageForGridCover() -> Bool {
        return self.imageDataForGridCover != nil
    }
    func hasImageForViewCover() -> Bool {
        return self.imageDataForViewCover != nil
    }
    func imageForGridCover() -> UIImage? {
        return UIImage(data: self.imageDataForGridCover!)
    }
    func imageForViewCover() -> UIImage? {
        return UIImage(data: self.imageDataForViewCover!)
    }
    
}
