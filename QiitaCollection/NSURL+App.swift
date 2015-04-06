//
//  NSURL+App.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/03/05.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

extension NSURL {
    
    enum Signin: String {
        case
        Host = "anz-note.tumblr.com",
        Path = "/qiitacollection-signin",
        Query = "code",
        Scope = "read_qiita write_qiita"
    }
    
    class func qiitaAuthorizeURL() -> NSURL {
        let scope: String = Signin.Scope.rawValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        return NSURL(string: "https://qiita.com/api/v2/oauth/authorize?scope=" + scope + "&client_id=" + ThirdParty.Qiita.ClientID.rawValue)!
    }
    
    func isQittaAfterSignIn() -> Bool {
        return Signin.Host.rawValue == self.host && Signin.Path.rawValue == self.path
    }
    
    func getAccessCode() -> String? {
        if let queryString = self.query {
            let queries:[String] = queryString.componentsSeparatedByString("&")
            
            for pairString in queries {
                
                let pair:[String] = pairString.componentsSeparatedByString("=")
                if Signin.Query.rawValue == pair[0] {
                    return pair[1]
                }
                
            }
            
            return nil
            
        } else {
            return nil
        }
    }
    
    func parse() -> (entryId: String?, userId: String?) {
        
        var result: (entryId: String?, userId: String?) = (entryId: nil, userId: nil)
        
        if let h = self.host {
            if h != "qiita.com" {
                return result
            }
        } else {
            return result
        }
        
        if var components = self.pathComponents {
            
            // 初めが url separator か
            if components[0] as String == "/" {
                components.removeAtIndex(0)
            }
            
            if (components.count == 1) {
                // ユーザーページの可能性
                let path = components[0] as String
                
                // qiita の静的ページチェック
                if !contains(["about", "tags", "advent-calendar", "organizations", "users", "license", "terms", "privacy", "asct", "drafts"], path) {
                    result.userId = path
                }
            } else if (components.count >= 3) {
                // 記事の可能性
                let path2 = components[1] as String
                if path2 == "items" {
                    result.entryId = components[2] as? String
                }
            }
            
        }
        
        return result
    }
    
}