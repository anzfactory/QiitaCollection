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
    
    var apiUrl: String {
        get { return "https://" + Host + "/api/" + ApiVersion}
    }
    
    func getEntriesNew(page: Int, completion:(items:[EntryEntity], isError: Bool) -> Void) {
        // テストアクセス
        let params = [
            "page" : String(page),
            "per_page" : "20"
        ]
        Alamofire.request(Alamofire.Method.GET, self.apiUrl + PathItems, parameters: params, encoding: ParameterEncoding.URL)
            .responseJSON { (request, response, jsonData, error) -> Void in
                
                let isError: Bool = error == nil ? false : true
                
                if isError {
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
}
