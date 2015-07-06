//
//  SimpleBrowserViewController.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/07/06.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class SimpleBrowserViewController: BaseViewController, UIWebViewDelegate {

    // MARK: UI
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var webview: UIWebView!
    @IBOutlet weak var navigationTitle: UINavigationItem!
    
    // MARK: プロパティ
    let titleView: NavigationTitleView = UINib(nibName: "NavigationTitleView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! NavigationTitleView
    var displayAdvent: AdventEntity? = nil {
        didSet {
            if let entity = self.displayAdvent {
                self.titleView.titleLabel.text = entity.title
            }
        }
    }
    
    
    // MARK: ライフサイクル
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationTitle.titleView = self.titleView
        self.webview.delegate = self
        
        self.setupForPresentedVC(self.navigationBar)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let entity = self.displayAdvent {
            self.webview.loadRequest(NSURLRequest(URL: NSURL(string: entity.url)!))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: アクション
    @IBAction func tapClose(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }
    
    // MARK: UIWebviewDelegate
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        switch navigationType {
        case UIWebViewNavigationType.LinkClicked: fallthrough
        case UIWebViewNavigationType.FormSubmitted: fallthrough
        case UIWebViewNavigationType.FormResubmitted:
            
            // 何かアクションした場合は、safari開く
            UIApplication.sharedApplication().openURL(NSURL(string: self.displayAdvent!.url)!)
            
            return false
        default:
            return true
        }
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        self.titleView.startIndicator()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        self.titleView.stopIndicator()
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        self.titleView.stopIndicator()
    }
}
