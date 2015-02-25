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

class QiitaApiManager: NSObject {
    
    let Host: String = "qiita.com"
    let ApiVersion: String = "v2"
    
    let PathItems: String = "/items"
    let PathItem: String = "/items/%@"
    let PathTag: String = "/tags/%@"
    let PathUser: String = "/users/%@"
    let PathUserStocks: String = "/users/%@/stocks"
    
    var apiUrl: String {
        get { return "https://" + Host + "/api/" + ApiVersion}
    }
    
    func getEntriesNew(page: Int, completion:(items:[EntryEntity], isError: Bool) -> Void) {
        self.getEntriesSearch(nil, page: page, completion: completion)
    }
    
    func getEntriesSearch(query: String?, page: Int, completion:(items:[EntryEntity], isError: Bool) -> Void) {
        var params: [String: String] = [
            "page"     : String(page),
            "per_page" : "20"
        ]
        if let q = query {
            if !q.isEmpty {
                params["query"] = q
            }
        }
        self.getItems(self.apiUrl + PathItems, parameters: params, completion: completion)
    }
    
    func getEntriesUserStocks(userId: String, page: Int, completion:(items:[EntryEntity], isError: Bool) -> Void) {
        var params: [String: String] = [
            "page" : String(page)
        ]
        self.getItems(self.apiUrl + String(format: PathUserStocks, userId), parameters: params, completion: completion)
    }
    
    func getTag(tagId: String, completion:(item: TagEntity?, isError: Bool) -> Void) {
        self.getItem(self.apiUrl + String(format: PathTag, tagId), parameters: nil, completion: completion)
    }
    
    func getUser(userId: String, completion:(item: UserEntity?, isError: Bool) -> Void) {
        self.getItem(self.apiUrl + String(format: PathUser, userId), parameters: nil, completion: completion)
    }
    
    func getEntry(entryId: String, completion:(item: EntryEntity?, isError: Bool) -> Void) {
        self.getItem(self.apiUrl + String(format: PathItem, entryId), parameters: nil, completion: completion)
    }
    
    func getItems<T:EntityProtocol>(url: URLStringConvertible, parameters: [String: AnyObject]?, completion: (items:[T], isError: Bool) -> Void) {
        
        Alamofire.request(Alamofire.Method.GET, url, parameters: parameters, encoding: ParameterEncoding.URL)
            .validate(statusCode: 200..<300)    // ステータスコードの200台以外をエラーとするように
            .responseJSON { (request, response, jsonData, error) -> Void in
                let isError: Bool = error == nil ? false : true
                
                var items: [T] = [T]()
                if isError {
                    completion(items:items, isError: isError);
                    return;
                }
                
                let json: JSON = JSON(jsonData!)
                if let list = json.array {
                    for obj in list {
                        items.append(T(data: obj));
                    }
                    completion(items: items, isError: isError);
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
                    completion(item: nil, isError: isError);
                    return;
                }
                let json = JSON(jsonData!)
                completion(item: T(data: json), isError: isError);
        }
    }
    
}
