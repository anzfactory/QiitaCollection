//
//  UserEntity.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/07.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit
import SwiftyJSON

struct UserEntity {
    
    let id: String
    let name: String
    var displayName: String { get { return "@" + id } }
    let introduction: String
    let organization: String
    let web: String
    let github: String
    let twitter: String
    let facebook: String
    let linkedin: String
    let location: String
    let profImage: String
    var profUrl: NSURL { get { return NSURL(string: profImage)! } }
    let itemCount: Int
    let followersCount: Int
    let followeesCount: Int
    
    init (data: [String : JSON]) {
        
        id = data["id"]!.string!
        name = data["name"]!.string!
        introduction = data["description"]?.string ?? ""
        organization = data["organization"]?.string ?? ""
        web = data["website_url"]?.string ?? ""
        github = data["github_login_name"]?.string ?? ""
        twitter = data["twitter_screen_name"]?.string ?? ""
        facebook = data["facebook_id"]?.string ?? ""
        linkedin = data["linkedin_id"]?.string ?? ""
        location = data["location"]?.string ?? ""
        profImage = data["profile_image_url"]?.string ?? ""
        itemCount = data["items_count"]?.intValue ?? 0
        followersCount = data["followers_count"]?.intValue ?? 0
        followeesCount = data["followees_count"]?.intValue ?? 0
    }
    
    init (data: JSON) {
        println("data:\(data)")
        id = data["id"].string!
        name = data["name"].string!
        introduction = data["description"].string ?? ""
        organization = data["organization"].string ?? ""
        web = data["website_url"].string ?? ""
        github = data["github_login_name"].string ?? ""
        twitter = data["twitter_screen_name"].string ?? ""
        facebook = data["facebook_id"].string ?? ""
        linkedin = data["linkedin_id"].string ?? ""
        location = data["location"].string ?? ""
        profImage = data["profile_image_url"].string ?? ""
        itemCount = data["items_count"].intValue ?? 0
        followersCount = data["followers_count"].intValue ?? 0
        followeesCount = data["followees_count"].intValue ?? 0
    }
    
    func loadThumb(imageView: UIImageView) {
        
        if self.profImage.isEmpty {
            imageView.image = UIImage(named: "default");
            return
        }
        
        imageView.sd_setImageWithURL(self.profUrl, completed: { (image, error, cacheType, url) -> Void in
            if error != nil {
                imageView.image = UIImage(named: "default")
                println("error..." + error.localizedDescription)
            }
        })
    }
}
