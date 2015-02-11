//
//  EntryDetailViewController.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/11.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class EntryDetailViewController: BaseViewController {

    // MARK: UI
    @IBOutlet weak var webView: UIWebView!
    
    // MARK: プロパティ
    var displayEntry: EntryEntity?
    
    // MARK: ライフサイクル
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // テンプレート読み込み
        let path: NSString = NSBundle.mainBundle().pathForResource("entry", ofType: "html")!
        let template: NSString = NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: nil)!
        // テンプレートに組み込んで表示
        self.webView.loadHTMLString(NSString(format: template, self.displayEntry!.title, self.displayEntry!.htmlBody), baseURL: nil)
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        println("\(self.view.frame)")
    }
}
