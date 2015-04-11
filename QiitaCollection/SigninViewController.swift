//
//  SigninViewController.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/03/06.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class SigninViewController: BaseViewController, UIWebViewDelegate {

    // MARK: UI
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var webView: UIWebView!
    
    // MARK: プロパティ
    var authorizationAction: ((SigninViewController, QiitaAccount) -> Void)? = nil
    
    // MARK: ライフサイクル
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupForPresentedVC(self.navigationBar)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.webView.loadRequest(NSURLRequest(URL: NSURL.qiitaAuthorizeURL()))
        self.webView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func tapClose(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }
    
    func authorize(code: String) {
        
       self.account.signin(code, completion: { (qiitaAccount) -> Void in
            
            if qiitaAccount == nil {
                Toast.show("認証処理に失敗しました....", style: JFMinimalNotificationStytle.StyleError, title: "", targetView: self.view)
                if self.webView.loading {
                    self.webView.stopLoading()
                }
                self.webView.loadRequest(NSURLRequest(URL: NSURL.qiitaAuthorizeURL()))
                return
            }
        
            self.account = qiitaAccount!
            if let action = self.authorizationAction {
                action(self, qiitaAccount!)
            }
            
        })
        
    }

    // MARK: UIWebViewDelegate
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        let url: NSURL = request.URL!
        
        if url.isQittaAfterSignIn() {
            if let code = url.getAccessCode() {
                
                // 取得したcodeを利用して認証
                self.authorize(code)
                
            }
        }
        
        return true
    }
}
