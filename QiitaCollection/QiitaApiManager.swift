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
    let PathItemsStockers: String = "/items/%@/stockers"
    
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
    
    func getEntry(entryId: String, completion:(item: EntryEntity?, isError: Bool) -> Void) {
        self.getItem(self.apiUrl(PathItem, arg:entryId), parameters: nil, completion: completion)
    }
    
    func getItems<T:EntityProtocol>(url: URLStringConvertible, parameters: [String: AnyObject]?, completion: (total:Int, items:[T], isError: Bool) -> Void) {
        
        Alamofire.request(Alamofire.Method.GET, url, parameters: parameters, encoding: ParameterEncoding.URL)
            .validate(statusCode: 200..<300)    // ステータスコードの200台以外をエラーとするように
            .responseJSON { (request, response, jsonData, error) -> Void in
                let isError: Bool = error == nil ? false : true

                var items: [T] = [T]()
                if isError {
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
        Alamofire.request(Alamofire.Method.GET, url, parameters: parameters, encoding: ParameterEncoding.URL)
            .validate(statusCode: 200..<300)    // ステータスコードの200台以外をエラーとするように
            .responseJSON { (request, response, jsonData, error) -> Void in
                
                let isError: Bool = error == nil ? false : true
                
                if isError {
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
    
}
