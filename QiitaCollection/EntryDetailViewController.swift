//
//  EntryDetailViewController.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/11.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class EntryDetailViewController: BaseViewController {
    
    typealias ParseItem = (label: String, value: String)

    // MARK: UI
    @IBOutlet weak var webView: EntryDetailView!
    
    // MARK: プロパティ
    var displayEntry: EntryEntity? = nil {
        willSet {
            self.title = newValue?.title
        }
    }
    var displayEntryId: String? = nil
    var useLocalFile: Bool = false
    var qiitaManager: QiitaApiManager = QiitaApiManager.sharedInstance
    
    lazy var links: [ParseItem] = self.parseLink()
    lazy var codes: [ParseItem] = self.parseCode()
    let patternLink: String = "<a.*?href=\\\"([http|https].*?)\\\".*?>(.*?)</a>"
    let patternCode: String = "\\`{3}(.*?)\\n((.|\\n)*?)\\`{3}"
    
    // MARK: ライフサイクル
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if !self.isBeingPresented() && !self.isMovingToParentViewController() {
            return
        }

        self.refresh()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // したに固定メニューボタンがあるんで、bottom padding をセットしておく
        self.webView.scrollView.contentInset.bottom = 44.0
    }
    
    
    // MARK: メソッド
    override func publicMenuItems() -> [PathMenuItem] {
        
        // ローカルファイルから読みだしてる場合は、リロードだけ
        if self.useLocalFile {
            let menuItemReload: QCPathMenuItem = QCPathMenuItem(mainImage: UIImage(named: "menu_reload")!)
            menuItemReload.action = {() -> Void in
                self.confirmReload()
                return
            }
            return [menuItemReload]
        }
        
        let menuItemLink: QCPathMenuItem = QCPathMenuItem(mainImage: UIImage(named: "menu_link")!)
        menuItemLink.action = {() -> Void in
            self.openLinks()
            return
        }
        let menuItemClip: QCPathMenuItem = QCPathMenuItem(mainImage: UIImage(named: "menu_clipboard")!)
        menuItemClip.action = {() -> Void in
            self.copyCode()
            return
        }
        let menuItemPin: QCPathMenuItem = QCPathMenuItem(mainImage: UIImage(named: "menu_pin")!)
        menuItemPin.action = {() -> Void in
            self.confirmPinEntry()
            return
        }
        let menuItemShare: QCPathMenuItem = QCPathMenuItem(mainImage: UIImage(named: "menu_share")!)
        menuItemShare.action = {() -> Void in
            self.shareEntry()
            return
        }
        let menuPerson: QCPathMenuItem = QCPathMenuItem(mainImage: UIImage(named: "menu_person")!)
        menuPerson.action = {() -> Void in
            self.moveUserDetail()
            return
        }
        let menuDiscus: QCPathMenuItem = QCPathMenuItem(mainImage: UIImage(named: "menu_discus")!)
        menuDiscus.action = {() -> Void in
            self.moveCommentList()
            return
        }
        let menuDownload: QCPathMenuItem = QCPathMenuItem(mainImage: UIImage(named: "menu_download")!)
        menuDownload.action = {() -> Void in
            self.confirmDownload()
        }
        let menuStockers: QCPathMenuItem = QCPathMenuItem(mainImage: UIImage(named: "menu_star")!)
        menuStockers.action = {() -> Void in
            self.moveStockers()
        }
        return [menuItemLink, menuItemClip, menuItemPin, menuDownload, menuItemShare, menuPerson, menuDiscus, menuStockers]
    }
    func refresh() {
        if let entry = self.displayEntry {
            self.displayEntryId = entry.id
            self.loadLocalHtml()
        } else if let entryId = self.displayEntryId {
            
            if self.useLocalFile {
                // ローカルファイルから読み出す
                let htmlBody: String = FileManager().read(entryId)
                if htmlBody.isEmpty {
                    Toast.show("投稿を取得できませんでした...", style: JFMinimalNotificationStytle.StyleWarning)
                    return
                }
                self.title = UserDataManager.sharedInstance.titleSavedEntry(entryId)
                self.loadLocalHtml(self.title!, body: htmlBody)
                
            } else {
                // 投稿IDだけ渡されてる状況なので、とってくる
                self.qiitaManager.getEntry(entryId, completion: { (item, isError) -> Void in
                    if isError {
                        Toast.show("投稿を取得できませんでした...", style: JFMinimalNotificationStytle.StyleWarning)
                        return
                    }
                    self.displayEntry = item
                    self.loadLocalHtml()
                })
            }
        } else {
            fatalError("unknown entry....")
        }

    }
    func loadLocalHtml() {
        self.loadLocalHtml(self.displayEntry!.title, body:self.displayEntry!.htmlBody)
    }
    func loadLocalHtml(title: String, body:String) {
        // テンプレート読み込み
        let path: NSString = NSBundle.mainBundle().pathForResource("entry", ofType: "html")!
        let template: NSString = NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: nil)!
        // テンプレートに組み込んで表示
        self.webView.loadHTMLString(NSString(format: template, title, body), baseURL: nil)
    }
    
    func shareEntry() {
        
        let args: [NSObject: AnyObject] = [
            QCKeys.ActivityView.Message.rawValue: self.displayEntry!.title,
            QCKeys.ActivityView.Link.rawValue   : self.displayEntry!.urlString
        ]
        
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.ShowActivityView.rawValue, object: self, userInfo: args)
    }
    
    func openLinks() {
        
        if self.links.count == 0 {
            Toast.show("開けるリンクがありません...", style: JFMinimalNotificationStytle.StyleWarning)
            return
        }
        var linkTitles: [String] = [String]()
        for item in self.links {
            linkTitles.append(item.label + ":" + item.value)
        }
        let listVC: SimpleListViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SimpleListVC") as SimpleListViewController
        listVC.title = "開くURLを選んで下さい"
        listVC.items = linkTitles
        listVC.swipableCell = false
        listVC.tapCallback = {(vc: SimpleListViewController, index: Int) -> Void in
            vc.dismissViewControllerAnimated(true, completion: { () -> Void in
                let item: ParseItem = self.links[index]
                self.openURL(item.value)
                return
            })
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PresentedViewController.rawValue, object: listVC)
        
    }
    
    func copyCode() {
        if self.codes.count == 0 {
            Toast.show("コードブロックがないようです...", style: JFMinimalNotificationStytle.StyleWarning)
            return
        }
        
        var codeHeadlines: [String] = [String]()
        for item in self.codes {
            codeHeadlines.append(item.label)
        }
        
        let listVC: SimpleListViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SimpleListVC") as SimpleListViewController
        listVC.title = "コピーするコードを選んでください"
        listVC.items = codeHeadlines
        listVC.swipableCell = false
        listVC.tapCallback = {(vc: SimpleListViewController, index: Int) -> Void in
            vc.dismissViewControllerAnimated(true, completion: { () -> Void in
                let item: ParseItem = self.codes[index]
                UIPasteboard.generalPasteboard().setValue(item.value, forPasteboardType: "public.utf8-plain-text")
                Toast.show("クリップボードにコピーしました", style: JFMinimalNotificationStytle.StyleSuccess)
            })
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PresentedViewController.rawValue, object: listVC)
    }
    
    func parseLink() -> [ParseItem] {
        return self.parseHtml(self.displayEntry!.htmlBody, pattern:self.patternLink)
    }
    
    func parseCode() -> [ParseItem] {
        return self.parseHtml(self.displayEntry!.body, pattern:self.patternCode)
    }
    
    func parseHtml(body:String, pattern: String) -> [ParseItem] {
        let nsBody: NSString = NSString(string: body)
        var error: NSError?
        let regex: NSRegularExpression? = NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.CaseInsensitive, error: &error)
        let mathes: [AnyObject]? = regex?.matchesInString(nsBody, options: NSMatchingOptions.allZeros, range: NSMakeRange(0, nsBody.length))
        var targets: [ParseItem] = [ParseItem]()
        
        let indexLabel: Int = pattern == self.patternLink ? 2 : 1
        let indexValue: Int = pattern == self.patternLink ? 1 : 2
        
        if let objects = mathes {
            for obj in objects {
                let result: NSTextCheckingResult = obj as NSTextCheckingResult
                var label: String = nsBody.substringWithRange(result.rangeAtIndex(indexLabel))
                let value: String = nsBody.substringWithRange(result.rangeAtIndex(indexValue))
                
                if (label.isEmpty) {
                    label = value.componentsSeparatedByString("\n")[0]
                } else if (pattern == self.patternCode) {
                    let separateLabel = label.componentsSeparatedByString(":")
                    if (separateLabel.count == 2) {
                        label = separateLabel[1] + ":" + value.componentsSeparatedByString("\n")[0]
                    } else {
                        label = separateLabel[0] + ":" + value.componentsSeparatedByString("\n")[0]
                    }
                }
                let item: ParseItem = ParseItem(label:label, value:value)
                targets.append(item)
            }
        }
        return targets
    }
    
    func openURL(urlString: String) {
        if let url = NSURL(string: urlString) {
            if UIApplication.sharedApplication().canOpenURL(url) {
                UIApplication.sharedApplication().openURL(url)
            } else {
                Toast.show("開くことが出来るURLではないようです…", style: JFMinimalNotificationStytle.StyleWarning)
            }
            
        } else {
            Toast.show("開くことが出来るURLではないようです…", style: JFMinimalNotificationStytle.StyleWarning)
            return
        }
        
    }
    
    func moveUserDetail() {
        let vc: UserDetailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("UserDetailVC") as UserDetailViewController
        vc.displayUserId = self.displayEntry!.postUser.id
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PushViewController.rawValue, object: vc)
    }
    
    func moveCommentList() {
        let vc: CommentListViewController = self.storyboard?.instantiateViewControllerWithIdentifier("CommentsVC") as CommentListViewController
        vc.displayEntryId = self.displayEntryId!
        vc.displayEntryTitle = self.displayEntry?.title ?? ""
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PushViewController.rawValue, object: vc)
    }
    
    func moveStockers() {
        let vc: UserListViewController = self.storyboard?.instantiateViewControllerWithIdentifier("UserListVC") as UserListViewController
        vc.listType = UserListViewController.UserListType.Stockers
        vc.targetEntryId = self.displayEntryId
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PushViewController.rawValue, object: vc)
    }
    
    func confirmPinEntry() {
        let action: AlertViewSender = AlertViewSender(action: { () -> Void in
            UserDataManager.sharedInstance.appendPinEntry(self.displayEntryId!, entryTitle: self.title!)
            Toast.show("この投稿をpinしました", style: JFMinimalNotificationStytle.StyleSuccess)
            return
        }, title: "OK")
        
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.ShowAlertYesNo.rawValue, object: nil, userInfo: [
            QCKeys.AlertView.Title.rawValue    : "確認",
            QCKeys.AlertView.Message.rawValue  : "この投稿をpinしますか？",
            QCKeys.AlertView.YesAction.rawValue: action,
            QCKeys.AlertView.NoTitle.rawValue  : "Cancel"
        ])
    }
    
    func confirmDownload() {
        let action: AlertViewSender = AlertViewSender(action: { () -> Void in
            
            let manager: FileManager = FileManager()
            if manager.save(self.displayEntry!.id, dataString: self.displayEntry!.htmlBody) {
                // 続けてタイトルとidをUDへ
                UserDataManager.sharedInstance.appendSavedEntry(self.displayEntry!.id, title: self.displayEntry!.title)
                Toast.show("この投稿を保存しました", style: JFMinimalNotificationStytle.StyleSuccess)
                NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.ReloadViewPager.rawValue, object: nil)
            } else {
                Toast.show("この投稿の保存に失敗しました", style: JFMinimalNotificationStytle.StyleError)
            }
            return
        }, title: "Save")
        
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.ShowAlertYesNo.rawValue, object: nil, userInfo: [
            QCKeys.AlertView.Title.rawValue    : "確認",
            QCKeys.AlertView.Message.rawValue  : "この投稿を保存しますか？保存するとオフラインでも閲覧できるようになります",
            QCKeys.AlertView.YesAction.rawValue: action,
            QCKeys.AlertView.NoTitle.rawValue  : "Cancel"
        ])
    }
    
    func confirmReload() {
        let action: AlertViewSender = AlertViewSender(action: {() -> Void in
            self.useLocalFile = false
            self.refresh()
            NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.ResetPublicMenuItems.rawValue, object: self)
        }, title: "OK")
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.ShowAlertYesNo.rawValue, object: nil, userInfo: [
            QCKeys.AlertView.Title.rawValue    : "確認",
            QCKeys.AlertView.Message.rawValue  : "現在保存した投稿ファイルを表示しています。最新状態をネットから取得しなおしますか？",
            QCKeys.AlertView.YesAction.rawValue: action,
            QCKeys.AlertView.NoTitle.rawValue  : "Cancel"
        ])
    }
    
}
