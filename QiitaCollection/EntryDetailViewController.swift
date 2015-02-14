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
    @IBOutlet weak var webView: EntryDetailView!
    
    // MARK: プロパティ
    var displayEntry: EntryEntity?
    lazy var links: [String] = self.parseLink()
    let patternLink = "(<a.*?href=\\\")([http|https].*?)(\\\".*?>)"
    
    // MARK: ライフサイクル
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.webView.callbackSelectedMenu = { (item: VLDContextSheetItem) -> Void in
            self.selectedContextMenu(item)
        }
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
    }
    
    // MARK: メソッド
    func selectedContextMenu(menuItem: VLDContextSheetItem) {
        
        if menuItem.title == self.webView.menuTitleShare {
            self.shareEntry()
        } else if menuItem.title == self.webView.menuTitleLinks {
            self.openLinks()
        }
        
    }
    
    func shareEntry() {
        
        var shareItems: [AnyObject] = [
            NSString(string: self.displayEntry!.title),
            NSURL(string: self.displayEntry!.urlString)!
        ]
        
        let shareVC: UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        self.presentViewController(shareVC, animated: true) { () -> Void in
            
        }
    }
    
    func openLinks() {
        
        if self.links.count == 0 {
            // TODO: アラート表示
            return
        }
        
        let makeAletAction = { (urlString: String) -> UIAlertAction in
            return UIAlertAction(title: urlString, style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
                self.openURL(urlString)
            })
        }
        
        var actions: [UIAlertAction] = [UIAlertAction]()
        for urlString in self.links {
            actions.append(makeAletAction(urlString))
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action) -> Void in
            
        }
        actions.append(cancelAction)
        
        NSNotificationCenter.defaultCenter()
            .postNotificationName(QCKeys.Notification.ShowActionSheet.rawValue,
                object: nil,
                userInfo: [
                    QCKeys.ActionSheet.Title.rawValue: "どのURLをひらきますか？",
                    QCKeys.ActionSheet.Actions.rawValue: actions
                ])
        
    }
    
    func parseLink() -> [String] {
        return self.parseHtml(self.patternLink)
    }
    
    func parseHtml(pattern: String) -> [String] {
        let nsBody: NSString = NSString(string: self.displayEntry!.htmlBody)
        var error: NSError?
        let regex: NSRegularExpression? = NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.CaseInsensitive, error: &error)
        let mathes: [AnyObject]? = regex?.matchesInString(nsBody, options: NSMatchingOptions.allZeros, range: NSMakeRange(0, nsBody.length))
        var targets: [String] = [String]()
        if (mathes != nil) {
            for v:AnyObject in mathes! {
                let a: NSTextCheckingResult = v as NSTextCheckingResult
                targets.append(nsBody.substringWithRange(a.rangeAtIndex(2)))
            }
        }
        return targets
    }
    
    func openURL(urlString: String) {
        if let url = NSURL(string: urlString) {
            UIApplication.sharedApplication().openURL(url)
        } else {
            // TODO alert
        }
        
    }
    
}
