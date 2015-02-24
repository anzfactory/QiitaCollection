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
            return false
        }
        return true
    }
    

}
