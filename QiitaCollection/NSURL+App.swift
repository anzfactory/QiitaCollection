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
        Scope = "read_qiita write_qiita_team"
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
    
}