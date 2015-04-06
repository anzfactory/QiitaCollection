//
//  EntryDetailView.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/14.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class EntryDetailView: UIWebView, UIWebViewDelegate {

    // MARK: ライフサイクル
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.delegate = self
        
    }
    
    // MARK: UIWebViewDelegate
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        if navigationType == UIWebViewNavigationType.LinkClicked {
            // リンククリックを無効化
            // 但し Qiita の 記事 あるいは ユーザー なら ViewController で開く
            let result = request.URL.parse()
            
            if let userId = result.userId {
                // ユーザーVCを開く
                let vc: UserDetailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("UserDetailVC") as UserDetailViewController
                vc.displayUserId = userId
                NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PushViewController.rawValue, object: vc)
            } else if let entryId = result.entryId {
                // 投稿VCを開く
                let vc: EntryDetailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("EntryDetailVC") as EntryDetailViewController
                vc.displayEntryId = entryId
                NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PushViewController.rawValue, object: vc)
            }
            
            return false
        }
        return true
    }
    

}
