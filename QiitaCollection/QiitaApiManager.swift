//
//  QiitaApiManager.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/07.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

import Alamofire
import SwiftyJSON

class QiitaApiManager {
    
    let Host: String = "qiita.com"
    let ApiVersion: String = "v2"
    
    let PathItems: String = "/items"
    let PathItem: String = "/items/%@"
    let PathTag: String = "/tags/%@"
    let PathUser: String = "/users/%@"
    let PathUserStocks: String = "/users/%@/stocks"
    let PathItemsComments: String = "/items/%@/comments"
    let PathItemsComment: String = "/comments/%@"
    let PathItemsStockers: String = "/items/%@/stockers"
    let PathAcessToken: String = "/access_tokens"
    let PathAuthenticatedUser: String = "/authenticated_user"
    let PathAuthenticatedUserItems: String = "/authenticated_user/items"
    let PathItemsStock: String = "/items/%@/stock"
    let PathUsersFollowing: String = "/users/%@/following"
    
    var manager: Alamofire.Manager!
    
    // シングルトンパターン
    class var sharedInstance : QiitaApiManager {
        struct Static {
            static let instance : QiitaApiManager = QiitaApiManager()
        }
        return Static.instance
    }
    
    init() {
        
        self.manager = Alamofire.Manager.sharedInstance
        
        // 認証済みならヘッダーにアクセストークンつける
        if UserDataManager.sharedInstance.isAuthorizedQiita() {
            self.setupHeader()
        }
        
    }
    
    func setupHeader() {
        var defaultHeaders = self.manager.session.configuration.HTTPAdditionalHeaders ?? [:]
        let headerVal = "Bearer " + UserDataManager.sharedInstance.qiitaAccessToken
        defaultHeaders["Authorization"] = headerVal
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = defaultHeaders
        self.manager = Alamofire.Manager(configuration: configuration)
    }
    
    func clearHeader() {
        var defaultHeaders = self.manager.session.configuration.HTTPAdditionalHeaders ?? [:]
        defaultHeaders.removeValueForKey("Authorization")
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = defaultHeaders
        self.manager = Alamofire.Manager(configuration: configuration)
    }
    
    func apiUrl(path:String, arg: String? = nil) -> String {
        let uri: String = "https://" + Host + "/api/" + ApiVersion
        if let argVal = arg {
            return uri + String(format: path, argVal.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
        } else {
            return uri + path
        }
    }
    
    func getEntriesNew(page: Int, completion:(total: Int, items:[EntryEntity], isError: Bool) -> Void) {
        self.getEntriesSearch(nil, page: page, completion: completion)
    }
    
    func getEntriesSearch(query: String?, page: Int, completion:(total: Int, items:[EntryEntity], isError: Bool) -> Void) {
        var params: [String: String] = [
            "page"     : String(page),
            "per_page" : "20"
        ]
        if let q = query {
            if !q.isEmpty {
                params["query"] = q
            }
        }
        self.getItems(self.apiUrl(PathItems), parameters: params, completion: completion)
    }
    
    func getEntriesUserStocks(userId: String, page: Int, completion:(total: Int, items:[EntryEntity], isError: Bool) -> Void) {
        var params: [String: String] = [
            "page" : String(page)
        ]
        self.getItems(self.apiUrl(PathUserStocks, arg:userId), parameters: params, completion: completion)
    }
    
    func getEntriesComments(entryId: String, page: Int, completion:(total: Int, items: [CommentEntity], isError: Bool) -> Void) {
        var params: [String: String] = [
            "page": String(page)
        ]
        self.getItems(self.apiUrl(PathItemsComments, arg:entryId), parameters: params, completion: completion)
    }
    
    func getStockers(entryId: String, page: Int, completion:(total: Int, items: [UserEntity], isError: Bool) -> Void) {
        var params: [String: String] = [
            "page": String(page)
        ]
        self.getItems(self.apiUrl(PathItemsStockers, arg:entryId), parameters: params, completion: completion)
    }
    
    func getTag(tagId: String, completion:(item: TagEntity?, isError: Bool) -> Void) {
        self.getItem(self.apiUrl(PathTag, arg:tagId), parameters: nil, completion: completion)
    }
    
    func getUser(userId: String, completion:(item: UserEntity?, isError: Bool) -> Void) {
        self.getItem(self.apiUrl(PathUser, arg:userId), parameters: nil, completion: completion)
    }
    
    func getAuthenticatedUser(completion:(item: UserEntity?, isError: Bool) -> Void) {
        self.getItem(self.apiUrl(PathAuthenticatedUser, arg:nil), parameters: nil, completion: completion)
    }
    
    func getAuthenticatedUserItems(page: Int, completion:(total: Int, items:[EntryEntity], isError: Bool) -> Void) {
        var params: [String: String] = [
            "page"     : String(page),
            "per_page" : "20"
        ]
        
        self.getItems(self.apiUrl(PathAuthenticatedUserItems), parameters: params, completion: completion)
    }
    
    func getUserFollowing(userId: String, completion:(isFollowing: Bool) -> Void) {
        self.getBool(self.apiUrl(PathUsersFollowing, arg: userId), completion: completion)
    }
    
    func getEntry(entryId: String, completion:(item: EntryEntity?, isError: Bool) -> Void) {
        self.getItem(self.apiUrl(PathItem, arg:entryId), parameters: nil, completion: completion)
    }
    
    func getItemStock(entryId: String, completion:(isStocked: Bool) -> Void) {
        self.getBool(self.apiUrl(PathItemsStock, arg: entryId), completion: completion)
    }
    
    func getBool(url: String, completion:(_: Bool) -> Void) {
        self.manager.request(Alamofire.Method.GET, url, parameters: nil, encoding: ParameterEncoding.URL)
            .validate(statusCode: 204..<205)    // code:204 が返ってくるので 204 以外を error扱いにしちゃう
            .responseJSON { (request, response, jsonData, error) -> Void in
                let isError: Bool = error == nil ? false : true
                completion(!isError)
        }
    }
    
    func getItems<T:EntityProtocol>(url: URLStringConvertible, parameters: [String: AnyObject]?, completion: (total:Int, items:[T], isError: Bool) -> Void) {
        
        self.manager.request(Alamofire.Method.GET, url, parameters: parameters, encoding: ParameterEncoding.URL)
            .validate(statusCode: 200..<300)    // ステータスコードの200台以外をエラーとするように
            .responseJSON { (request, response, jsonData, error) -> Void in
                let isError: Bool = error == nil ? false : true

                var items: [T] = [T]()
                if isError {
                    println(jsonData)
                    self.alertLimitRequest(jsonData)
                    completion(total:0, items:items, isError: isError);
                    return;
                }
                
                let json: JSON = JSON(jsonData!)
                let total: Int = response?.allHeaderFields["Total-Count"]?.integerValue ?? 0
                if let list = json.array {
                    for obj in list {
                        items.append(T(data: obj));
                    }
                    completion(total:total, items: items, isError: isError);
                } else {
                    fatalError("unmatch type......")
                }
                
        }
    }
    
    func getItem<T:EntityProtocol>(url: URLStringConvertible, parameters: [String: AnyObject]?, completion: (item:T?, isError: Bool) -> Void) {
        self.manager.request(Alamofire.Method.GET, url, parameters: parameters, encoding: ParameterEncoding.URL)
            .validate(statusCode: 200..<300)    // ステータスコードの200台以外をエラーとするように
            .responseJSON { (request, response, jsonData, error) -> Void in
                
                let isError: Bool = error == nil ? false : true
                
                if isError {
                    println(jsonData)
                    self.alertLimitRequest(jsonData)
                    completion(item: nil, isError: isError);
                    return;
                }
                let json = JSON(jsonData!)
                completion(item: T(data: json), isError: isError);
        }
    }
    
    func alertLimitRequest(response: AnyObject?) {
        if let res: AnyObject = response  {

            let json: JSON = JSON(res)
            if let dic: Dictionary = json.dictionary {
                if dic["type"] == "rate_limit_exceeded" {
                    let args: [NSObject: AnyObject] = [
                        QCKeys.AlertController.Title.rawValue: "リクエスト制限",
                        QCKeys.AlertController.Description.rawValue: "リクエスト制限に達したためデータ取得ができませんでした\n1時間毎に制限はリセットされるので、しらばらく時間をあけてから再度お試し下さい",
                        QCKeys.AlertController.Actions.rawValue: [UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
                            return
                        })],
                        QCKeys.AlertController.Style.rawValue: UIAlertControllerStyle.Alert.rawValue
                    ]
                    NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.ShowAlertController.rawValue, object: nil, userInfo: args)
                }
            }
            
        }
    }
    
    
    func postAuthorize(clientId: String, clientSecret: String, code: String, completion: ((token: String, isError: Bool) -> Void)) {
        
        let params: [String: String] = [
            "client_id"    : clientId,
            "client_secret": clientSecret,
            "code"         : code
        ]
        
        self.manager.request(Alamofire.Method.POST, self.apiUrl(PathAcessToken, arg: nil), parameters: params, encoding: ParameterEncoding.JSON)
            .validate(statusCode: 200..<300)    // ステータスコードの200台以外をエラーとするように
            .responseJSON { (request, response, jsonData, error) -> Void in
                
                let isError: Bool = error == nil ? false : true
                if isError {
                    println(jsonData)
                    completion(token: "", isError: isError);
                    return;
                }
                let json = JSON(jsonData!)
                completion(token: json["token"].string!, isError: isError);
        }
    }
    
    func postComment(entryId: String, body: String, completion:((isError: Bool) -> Void)) {
        let params: [String: String] = [
            "body": body
        ]
        
        self.manager.request(Alamofire.Method.POST, self.apiUrl(PathItemsComments, arg: entryId), parameters: params, encoding: ParameterEncoding.JSON)
            .validate(statusCode: 200..<300)    // ステータスコードの200台以外をエラーとするように
            .responseJSON { (request, response, jsonData, error) -> Void in
                
                let isError: Bool = error == nil ? false : true
                if isError {
                    println(jsonData)
                }
                completion(isError: isError)
        }
    }
    
    func putItemStock(entryId: String, completion: (isError: Bool) -> Void) {
        
        let url: String = self.apiUrl(PathItemsStock, arg: entryId)
        self.put(url, completion: completion)
    }
    
    func putUserFollowing(userId: String, completion: (isError: Bool) -> Void) {
        let url: String = self.apiUrl(PathUsersFollowing, arg: userId)
        self.put(url, completion: completion)
    }
    
    func put(url: String, completion: (isError: Bool) -> Void) {
        self.manager.request(Alamofire.Method.PUT, url, parameters: nil, encoding: ParameterEncoding.JSON)
            .validate(statusCode: 200..<300)    // ステータスコードの200台以外をエラーとするように
            .responseJSON { (request, response, jsonData, error) -> Void in
                
                let isError: Bool = error == nil ? false : true
                
                if isError {
                    println(jsonData)
                } else {
                    NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.ShowInterstitial.rawValue, object: nil)
                }
                
                completion(isError: isError)
        }
    }
    
    func patchComment(commentId: String, body: String, completion: ((isError: Bool) -> Void)) {
        let params: [String: String] = [
            "body": body
        ]
        
        self.manager.request(Alamofire.Method.PATCH, self.apiUrl(PathItemsComment, arg: commentId), parameters: params, encoding: ParameterEncoding.JSON)
        .validate(statusCode: 200..<300)    // ステータスコードの200台以外をエラーとするように
        .responseJSON { (request, response, jsonData, error) -> Void in
            
            let isError: Bool = error == nil ? false : true
            if isError {
                println(jsonData)
            } else {
                NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.ShowInterstitial.rawValue, object: nil)
            }
            completion(isError: isError)
        }
    }
    
    func deleteAccessToken(token: String, completion:((isError: Bool) -> Void)) {
        let url: String = self.apiUrl(PathAcessToken, arg: nil) + "/" + token
        self.delete(url, parameters: nil, completion: completion)
    }
    
    func deleteItemStock(entryId: String, completion: (isError: Bool) -> Void) {
        let url: String = self.apiUrl(PathItemsStock, arg: entryId)
        self.delete(url, parameters: nil, completion: completion)
    }
    
    func deleteUserFollowing(userId: String, completion: (isError: Bool) -> Void) {
        let url: String = self.apiUrl(PathUsersFollowing, arg: userId)
        self.delete(url, parameters: nil, completion: completion)
    }
    
    func deleteComment(commentId: String, completion:((isError: Bool) -> Void)) {
        let url: String = self.apiUrl(PathItemsComment, arg: commentId)
        self.delete(url, parameters: nil, completion: completion)
    }
    
    func delete(url: String, parameters: [String : AnyObject]?, completion: (isError: Bool) -> Void) {
        self.manager.request(Alamofire.Method.DELETE, url, parameters: parameters, encoding: ParameterEncoding.JSON)
            .validate(statusCode: 200..<300)    // ステータスコードの200台以外をエラーとするように
            .responseJSON { (request, response, jsonData, error) -> Void in
                let isError: Bool = error == nil ? false : true
                if isError {
                    println(jsonData)
                } else {
                    NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.ShowInterstitial.rawValue, object: nil)
                }
                completion(isError: isError);
        }
    }
}
