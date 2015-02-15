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
    let PathTag: String = "/tags/%@"
    let PathUser: String = "/users/%@"
    
    var apiUrl: String {
        get { return "https://" + Host + "/api/" + ApiVersion}
    }
    
    func getEntriesNew(page: Int, completion:(items:[EntryEntity], isError: Bool) -> Void) {
        self.getEntriesSearch(nil, page: page, completion: completion)
    }
    
    func getEntriesSearch(query: String?, page: Int, completion:(items:[EntryEntity], isError: Bool) -> Void) {
        var params: [String: String] = [
            "page" : String(page),
            "per_page" : "20"
        ]
        if let q = query {
            params["query"] = q
        }
        
        Alamofire.request(Alamofire.Method.GET, self.apiUrl + PathItems, parameters: params, encoding: ParameterEncoding.URL)
            .responseJSON { (request, response, jsonData, error) -> Void in
                
                let isError: Bool = error == nil ? false : true
                
                if isError {
                    completion(items: [], isError: isError);
                    return;
                } else if !(jsonData is NSArray) {
                    println("response:\(jsonData)")
                    completion(items: [], isError: isError);
                    return;
                }
                let json = jsonData as NSArray
                var items = [EntryEntity]()
                for obj in json {
                    items.append(EntryEntity(data:JSON(obj)));
                }
                
                completion(items: items, isError: isError);
        }
    }
    
    func getTag(tagId: String, completion:(item: TagEntity?, isError: Bool) -> Void) {
        
        Alamofire.request(Alamofire.Method.GET, self.apiUrl + String(format: PathTag, tagId), parameters: nil, encoding: ParameterEncoding.URL)
            .responseJSON { (request, response, jsonData, error) -> Void in
                
                let isError: Bool = error == nil ? false : true
                
                if isError {
                    completion(item:nil, isError: isError);
                    return;
                }

                let json = JSON(jsonData!)
                let tag: TagEntity = TagEntity(data: json )
                
                completion(item: tag, isError: isError);
        }
    }
    
    func getUser(userId: String, completion:(item: UserEntity?, isError: Bool) -> Void) {
        
        Alamofire.request(Alamofire.Method.GET, self.apiUrl + String(format: PathUser, userId), parameters: nil, encoding: ParameterEncoding.URL)
            .responseJSON { (request, response, jsonData, error) -> Void in
                let isError: Bool = error == nil ? false : true
                
                if isError {
                    completion(item:nil, isError: isError);
                    return;
                }
                
                let json = JSON(jsonData!)
                let user: UserEntity = UserEntity(data: json )
                
                completion(item: user, isError: isError);
        }
        
    }
    
}
