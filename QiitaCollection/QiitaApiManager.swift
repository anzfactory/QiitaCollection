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
    
    // ルーティング を設定しつつ HTTPヘッダーを設定する
    enum Router: URLRequestConvertible {
        
        static let baseUrlString = "https://qiita.com/api/v2"
        static let perPage = 20
        
        case
        GetEntriesNew(page: Int),
        GetEntriesSearch(query: String, page: Int),
        GetEntriesUserStocks(userId: String, page: Int),
        GetEntriesComments(entryId: String, page: Int),
        GetStockers(entryId: String, page: Int),
        GetTag(tagId: String),
        GetUser(userId: String),
        GetAuthenticatedUser,
        GetAuthenticatedUserItems(page: Int),
        GetUserFollowing(userId: String),
        GetEntry(entryId: String),
        GetItemStock(entryId: String),
        PostAuthorize(clientId: String, clientSecret: String, code: String),
        PostComment(entryId: String, body: String),
        PutItemStock(entryId: String),
        PutUserFollowing(userId: String),
        PatchComment(commentId: String, body: String),
        DeleteAccessToken(token: String),
        DeleteItemStock(entryId: String),
        DeleteUserFollowing(userId: String),
        DeleteComment(commentId: String)
        
        var endpoint: (method: Alamofire.Method, path: String, params: [String: AnyObject]?, encoding: ParameterEncoding) {
            switch self {
            case .GetEntriesNew(let page):
                return (method: .GET, path: "/items", params: ["page": page, "per_page": Router.perPage], encoding: .URL)
            case .GetEntriesSearch(let query, let page):
                var params: [String: AnyObject] = ["page": page, "per_page": Router.perPage]
                if !query.isEmpty {
                    params["query"] = query
                }
                return (method: .GET, path: "/items", params: params, encoding: .URL)
            case .GetEntriesUserStocks(let userId, let page):
                return (method: .GET, path: "/users/\(userId)/stocks", params: ["page": page], encoding: .URL)
            case .GetEntriesComments(let entryId, let page):
                return (method: .GET, path: "/items/\(entryId)/comments", params: ["page": page], encoding: .URL)
            case .GetStockers(let entryId, let page):
                return (method: .GET, path: "/items/\(entryId)/stockers", params: ["page": page], encoding: .URL)
            case .GetTag(let tagId):
                return (method: .GET, path: "/tags/" + tagId, params: nil, encoding: .URL)
            case .GetUser(let userId):
                return (method: .GET, path: "/users/" + userId, params: nil, encoding: .URL)
            case .GetAuthenticatedUser:
                return (method: .GET, path: "/authenticated_user", params: nil, encoding: .URL)
            case .GetAuthenticatedUserItems(let page):
                return (method: .GET, path: "/authenticated_user/items", params: ["page": page], encoding: .URL)
            case .GetUserFollowing(let userId):
                return (method: .GET, path: "/users/\(userId)/following", params: nil, encoding: .URL)
            case .GetEntry(let entryId):
                return (method: .GET, path: "/items/" + entryId, params: nil, encoding: .URL)
            case .GetItemStock(let entryId):
                return (method: .GET, path: "/items/\(entryId)/stock", params: nil, encoding: .URL)
            case .PostAuthorize(let clientId, let clientSecret, let code):
                return (method: .POST, path: "/access_tokens", params: [
                    "client_id"    : clientId,
                    "client_secret": clientSecret,
                    "code"         : code
                ], encoding: .JSON)
            case .PostComment(let entryId, let body):
                return (method: .POST, path: "/items/\(entryId)/comments", params: ["body": body], encoding: .JSON)
            case .PutItemStock(let entryId):
                return (method: .PUT, path: "/items/\(entryId)/stock", params: nil, encoding: .JSON)
            case .PutUserFollowing(let userId):
                return (method: .PUT, path: "/users/\(userId)/following", params: nil, encoding: .JSON)
            case .PatchComment(let commentId, let body):
                return (method: .PATCH, path: "/comments/" + commentId, params: ["body": body], encoding: .JSON)
            case .DeleteAccessToken(let token):
                return (method: .DELETE, path: "/access_tokens/" + token, params: nil, encoding: .JSON)
            case .DeleteItemStock(let entryId):
                return (method: .DELETE, path: "/items/\(entryId)/stock", params: nil, encoding: .JSON)
            case .DeleteUserFollowing(let userId):
                return (method: .DELETE, path: "/users/\(userId)/following", params: nil, encoding: .JSON)
            case .DeleteComment(let commentId):
                return (method: .DELETE, path: "/comments/" + commentId, params: nil, encoding: .JSON)
            }
        }
        
        var URLRequest: NSURLRequest {
            
            let URL = NSURL(string: Router.baseUrlString)!
            let endpoint = self.endpoint
            let URLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(endpoint.path))
            URLRequest.HTTPMethod = endpoint.method.rawValue
            
            // Qiita のアクセストークンがあればセットする
            if UserDataManager.sharedInstance.isAuthorizedQiita() {
                let headerVal = "Bearer " + UserDataManager.sharedInstance.qiitaAccessToken
                println(headerVal)
                URLRequest.setValue(headerVal, forHTTPHeaderField: "Authorization")
            } else {
                println("qiitaAccessToken is empty")
            }
            return endpoint.encoding.encode(URLRequest, parameters: endpoint.params).0
        }
    }
    
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
    }
    
    func getEntriesNew(page: Int, completion:(total: Int, items:[EntryEntity], isError: Bool) -> Void) {
        self.getItems(Router.GetEntriesNew(page: page), completion: completion)
    }
    
    func getEntriesSearch(query: String, page: Int, completion:(total: Int, items:[EntryEntity], isError: Bool) -> Void) {
        self.getItems(Router.GetEntriesSearch(query: query, page: page), completion: completion)
    }
    
    func getEntriesUserStocks(userId: String, page: Int, completion:(total: Int, items:[EntryEntity], isError: Bool) -> Void) {
        self.getItems(Router.GetEntriesUserStocks(userId: userId, page: page), completion: completion)
    }
    
    func getEntriesComments(entryId: String, page: Int, completion:(total: Int, items: [CommentEntity], isError: Bool) -> Void) {
        self.getItems(Router.GetEntriesComments(entryId: entryId, page: page), completion: completion)
    }
    
    func getStockers(entryId: String, page: Int, completion:(total: Int, items: [UserEntity], isError: Bool) -> Void) {
        self.getItems(Router.GetStockers(entryId: entryId, page: page), completion: completion)
    }
    
    func getTag(tagId: String, completion:(item: TagEntity?, isError: Bool) -> Void) {
        self.getItem(Router.GetTag(tagId: tagId), completion: completion)
    }
    
    func getUser(userId: String, completion:(item: UserEntity?, isError: Bool) -> Void) {
        self.getItem(Router.GetUser(userId: userId), completion: completion)
    }
    
    func getAuthenticatedUser(completion:(item: UserEntity?, isError: Bool) -> Void) {
        self.getItem(Router.GetAuthenticatedUser, completion: completion)
    }
    
    func getAuthenticatedUserItems(page: Int, completion:(total: Int, items:[EntryEntity], isError: Bool) -> Void) {
        self.getItems(Router.GetAuthenticatedUserItems(page: page), completion: completion)
    }
    
    func getUserFollowing(userId: String, completion:(isFollowing: Bool) -> Void) {
        self.getBool(Router.GetUserFollowing(userId: userId), completion: completion)
    }
    
    func getEntry(entryId: String, completion:(item: EntryEntity?, isError: Bool) -> Void) {
        self.getItem(Router.GetEntry(entryId: entryId), completion: completion)
    }
    
    func getItemStock(entryId: String, completion:(isStocked: Bool) -> Void) {
        self.getBool(Router.GetItemStock(entryId: entryId), completion: completion)
    }
    
    func getBool(request: URLRequestConvertible, completion:(_: Bool) -> Void) {
        self.manager.request(request)
            .validate(statusCode: 204..<205)    // code:204 が返ってくるので 204 以外を error扱いにしちゃう
            .responseJSON { (request, response, jsonData, error) -> Void in
                let isError: Bool = error == nil ? false : true
                completion(!isError)
        }
    }
    
    func getItems<T:EntityProtocol>(request: URLRequestConvertible, completion: (total:Int, items:[T], isError: Bool) -> Void) {
        
        self.manager.request(request)
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
    
    func getItem<T:EntityProtocol>(request: URLRequestConvertible, completion: (item:T?, isError: Bool) -> Void) {
        self.manager.request(request)
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
    
    func postAuthorize(clientId: String, clientSecret: String, code: String, completion: ((token: String, isError: Bool) -> Void)) {
        self.manager.request(Router.PostAuthorize(clientId: clientId, clientSecret: clientSecret, code: code))
            .validate(statusCode: 200..<300)    // ステータスコードの200台以外をエラーとするように
            .responseJSON { (request, response, jsonData, error) -> Void in
                
                let isError: Bool = error == nil ? false : true
                if isError {
                    println("post autholize:\(jsonData)")
                    completion(token: "", isError: isError);
                    return;
                }
                let json = JSON(jsonData!)
                completion(token: json["token"].string!, isError: isError);
        }
    }
    
    func postComment(entryId: String, body: String, completion:((isError: Bool) -> Void)) {
        self.manager.request(Router.PostComment(entryId: entryId, body: body))
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
        self.put(Router.PutItemStock(entryId: entryId), completion: completion)
    }
    
    func putUserFollowing(userId: String, completion: (isError: Bool) -> Void) {
        self.put(Router.PutUserFollowing(userId: userId), completion: completion)
    }
    
    func put(request: URLRequestConvertible, completion: (isError: Bool) -> Void) {
        self.manager.request(request)
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
        self.manager.request(Router.PatchComment(commentId: commentId, body: body))
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
        self.delete(Router.DeleteAccessToken(token: token), completion: completion)
    }
    
    func deleteItemStock(entryId: String, completion: (isError: Bool) -> Void) {
        self.delete(Router.DeleteItemStock(entryId: entryId), completion: completion)
    }
    
    func deleteUserFollowing(userId: String, completion: (isError: Bool) -> Void) {
        self.delete(Router.DeleteUserFollowing(userId: userId), completion: completion)
    }
    
    func deleteComment(commentId: String, completion:((isError: Bool) -> Void)) {
        self.delete(Router.DeleteComment(commentId: commentId), completion: completion)
    }
    
    func delete(request: URLRequestConvertible, completion: (isError: Bool) -> Void) {
        self.manager.request(request)
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
}
