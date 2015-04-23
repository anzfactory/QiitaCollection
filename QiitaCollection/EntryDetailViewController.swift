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
        didSet {
            if let entry = self.displayEntry {
                self.account.saveHistory(entry, isRanking: false)
            }
        }
    }
    var displayEntryId: String? = nil
    var useLocalFile: Bool = false
    var navButtonHandOff: SelectedBarButton? = nil
    var navButtonStock: SelectedBarButton? = nil
    
    lazy var links: [ParseItem] = self.parseLink()
    lazy var codes: [ParseItem] = self.parseCode()
    let patternLink: String = "<a.*?href=\\\"([http|https].*?)\\\".*?>(.*?)</a>"
    let patternCode: String = "\\`{3}(.*?)\\n((.|\\n)*?)\\`{3}"
    var senderActivity: NSUserActivity? = nil
    
    // MARK: ライフサイクル
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if !self.isBeingPresented() && !self.isMovingToParentViewController() {
            return
        }
        
        // ローカルファイルじゃない かつ 認証済みなら
        if !self.useLocalFile {
            self.setupNavigationBar()
        }

        self.refresh()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // したに固定メニューボタンがあるんで、bottom padding をセットしておく
        self.webView.scrollView.contentInset.bottom = 44.0
        
        if let barbutton = self.navButtonStock {
            barbutton.showGuide(GuideManager.GuideType.AddStock)
        }
        if let barbutton = self.navButtonHandOff {
            barbutton.showGuide(GuideManager.GuideType.SyncBrowsing)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        if let activity = self.senderActivity {
            activity.invalidate()
        }
        if self.isMovingFromParentViewController() || self.isBeingDismissed() {
            if let entry = self.displayEntry {
                self.account.saveHistory(entry, isRanking: true)
            }
        }
        super.viewWillDisappear(animated)
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
        let menuTags: QCPathMenuItem = QCPathMenuItem(mainImage: UIImage(named: "menu_tag")!)
        menuTags.action = {() -> Void in
            self.openTagList()
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
        return [menuItemLink, menuItemClip, menuItemPin, menuDownload, menuItemShare, menuPerson, menuDiscus, menuTags, menuStockers]
    }
    
    func setupNavigationBar() {
        
        var buttons: [SelectedBarButton] = [SelectedBarButton]()
        
        if self.account is QiitaAccount {
            // ストック
            self.navButtonStock = SelectedBarButton(image: UIImage(named: "bar_item_bookmark"), style: UIBarButtonItemStyle.Plain, target: self, action: "confirmAddStock")
            self.navButtonStock!.selectedColor = UIColor.tintSelectedBarButton()
            buttons.append(self.navButtonStock!)
        }
        
        // macへのブラウジング同期
        self.navButtonHandOff = SelectedBarButton(image: UIImage(named: "bar_item_desktop"), style: UIBarButtonItemStyle.Plain, target:self, action:"syncBrowsing")
        buttons.append(self.navButtonHandOff!)
       
        self.navigationItem.rightBarButtonItems = buttons

    }
    
    func refresh() {
        if let entry = self.displayEntry {
            self.displayEntryId = entry.id
            self.loadLocalHtml()
            self.getStockState(entry.id)
        } else if let entryId = self.displayEntryId {
            
            if self.useLocalFile {
                // ローカルファイルから読み出す
                self.account.loadLocalEntry(entryId, completion: { (isError, title, body) -> Void in
                    if isError {
                        Toast.show("投稿を取得できませんでした...", style: JFMinimalNotificationStytle.StyleWarning)
                        return
                    }
                    self.title = title
                    self.loadLocalHtml(self.title!, body: body)
                })
                
            } else {
                // 投稿IDだけ渡されてる状況なので、とってくる
                self.account.read(entryId, completion: { (entry) -> Void in
                    if entry == nil {
                        Toast.show("投稿を取得できませんでした...", style: JFMinimalNotificationStytle.StyleWarning)
                        return
                    }
                    self.displayEntry = entry
                    self.loadLocalHtml()
                    // 記事のストック状況を取得
                    self.getStockState(entryId)
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
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in

            // テンプレート読み込み
            let path: NSString = NSBundle.mainBundle().pathForResource("entry", ofType: "html")!
            let template: NSString = NSString(contentsOfFile: path as String, encoding: NSUTF8StringEncoding, error: nil)!
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                // テンプレートに組み込んで表示
                self.webView.loadHTMLString(NSString(format: template, title, body) as String, baseURL: nil)
            })
            
        })
        
    }
    
    func getStockState(entryId: String) {
        
        if let qiitaAccount = self.account as? QiitaAccount {
            qiitaAccount.isStocked(entryId, completion: { (stocked) -> Void in
                self.navButtonStock?.selected = stocked
                return
            })
        }
    }
    
    func syncBrowsing() {
        
        if let entry = self.displayEntry {
            
            if let activity = self.senderActivity {
                
            } else {
                self.senderActivity = NSUserActivity(activityType: QCKeys.UserActivity.TypeSendURLToMac.rawValue)
                self.senderActivity!.title = "QiitaCollection"
                self.senderActivity!.becomeCurrent();
            }
            self.senderActivity!.webpageURL = NSURL(string: entry.urlString)
            
            Toast.show("閲覧中の投稿をHandoff対応デバイスとシンクロしました", style: JFMinimalNotificationStytle.StyleSuccess)
        } else {
            Toast.show("投稿データがないようです...", style: JFMinimalNotificationStytle.StyleWarning)
        }
        
    }
    
    func confirmAddStock() {
        
        var message: String = ""
        if self.navButtonStock!.selected {
            message = "この投稿のストックを解除しますか？"
        } else {
            message = "この投稿をストックしますか？"
        }
        
        let args = [
            QCKeys.AlertView.Title.rawValue    : "確認",
            QCKeys.AlertView.Message.rawValue  : message,
            QCKeys.AlertView.NoTitle.rawValue  : "Cancel",
            QCKeys.AlertView.YesAction.rawValue: AlertViewSender(action: { () -> Void in
                self.toggleStock()
            }, title: "OK")
        ]
        
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.ShowAlertYesNo.rawValue, object: nil, userInfo: args)
    }
    
    func toggleStock() {
        
        if let qiitaAccount = self.account as? QiitaAccount {
            var message: String = ""
            let completion = {(isError: Bool) -> Void in
                
                if isError {
                    Toast.show("失敗しました…", style: JFMinimalNotificationStytle.StyleError)
                    return
                }
                
                // 処理後なんできめうちでもいいけど・・・ストック状態をとりなおしてみる
                self.getStockState(self.displayEntryId!)
                Toast.show(message, style: JFMinimalNotificationStytle.StyleSuccess)
                return
            }
            
            if self.navButtonStock!.selected {
                // 解除処理
                message = "ストックを解除しました"
                qiitaAccount.cancelStock(self.displayEntryId!, completion: completion)
            } else {
                // ストック処理
                message = "ストックしました"
                qiitaAccount.stock(self.displayEntryId!, completion: completion)
            }
            
        }
        
    }
    
    func shareEntry() {
        
        if self.displayEntry == nil {
            return
        }
        
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
        let listVC: SimpleListViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SimpleListVC") as! SimpleListViewController
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
        
        let listVC: SimpleListViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SimpleListVC") as! SimpleListViewController
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
        
        if self.displayEntry == nil {
            return [ParseItem]()
        }
        
        return self.parseHtml(self.displayEntry!.htmlBody, pattern:self.patternLink)
    }
    
    func parseCode() -> [ParseItem] {
        if self.displayEntry == nil {
            return [ParseItem]()
        }
        return self.parseHtml(self.displayEntry!.body, pattern:self.patternCode)
    }
    
    func parseHtml(body:String, pattern: String) -> [ParseItem] {
        let nsBody: NSString = NSString(string: body)
        var error: NSError?
        let regex: NSRegularExpression? = NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.CaseInsensitive, error: &error)
        let mathes: [AnyObject]? = regex?.matchesInString(nsBody as String, options: NSMatchingOptions.allZeros, range: NSMakeRange(0, nsBody.length))
        var targets: [ParseItem] = [ParseItem]()
        
        let indexLabel: Int = pattern == self.patternLink ? 2 : 1
        let indexValue: Int = pattern == self.patternLink ? 1 : 2
        
        if let objects = mathes {
            for obj in objects {
                let result: NSTextCheckingResult = obj as! NSTextCheckingResult
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
            
            let result = url.parse()
            if let userId = result.userId {
                // ユーザーVCを開く
                let vc: UserDetailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("UserDetailVC") as! UserDetailViewController
                vc.displayUserId = userId
                NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PushViewController.rawValue, object: vc)
            } else if let entryId = result.entryId {
                // 投稿VCを開く
                let vc: EntryDetailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("EntryDetailVC") as! EntryDetailViewController
                vc.displayEntryId = entryId
                NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PushViewController.rawValue, object: vc)
            } else {
                // ブラウザで開く
                if UIApplication.sharedApplication().canOpenURL(url) {
                    UIApplication.sharedApplication().openURL(url)
                } else {
                    Toast.show("開くことが出来るURLではないようです…", style: JFMinimalNotificationStytle.StyleWarning)
                }
            }
            
        } else {
            Toast.show("開くことが出来るURLではないようです…", style: JFMinimalNotificationStytle.StyleWarning)
            return
        }
        
    }
    
    func moveUserDetail() {
        
        if self.displayEntry == nil {
            return
        }
        
        let vc: UserDetailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("UserDetailVC") as! UserDetailViewController
        vc.displayUserId = self.displayEntry!.postUser.id
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PushViewController.rawValue, object: vc)
    }
    
    func moveCommentList() {
        
        if self.displayEntry == nil {
            return
        }
        
        let vc: CommentListViewController = self.storyboard?.instantiateViewControllerWithIdentifier("CommentsVC") as! CommentListViewController
        vc.displayEntryId = self.displayEntryId!
        vc.displayEntryTitle = self.displayEntry?.title ?? ""
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PushViewController.rawValue, object: vc)
    }
    
    func moveStockers() {
        
        if self.displayEntry == nil {
            return
        }
        
        let vc: UserListViewController = self.storyboard?.instantiateViewControllerWithIdentifier("UserListVC") as! UserListViewController
        vc.listType = UserListViewController.UserListType.Stockers
        vc.targetEntryId = self.displayEntryId
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PushViewController.rawValue, object: vc)
    }
    
    func confirmPinEntry() {
        
        if self.displayEntry == nil {
            return
        }
        
        let action: AlertViewSender = AlertViewSender(action: { () -> Void in
            self.account.pin(self.displayEntry!)
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
        
        if self.displayEntry == nil {
            return
        }
        
        let action: AlertViewSender = AlertViewSender(action: { () -> Void in
            
            self.account.download(self.displayEntry!, completion: { (isError) -> Void in
                if isError {
                    Toast.show("この投稿の保存に失敗しました", style: JFMinimalNotificationStytle.StyleError)
                } else {
                    // ViewPager再構成指示
                    NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.ReloadViewPager.rawValue, object: nil)
                    Toast.show("この投稿を保存しました", style: JFMinimalNotificationStytle.StyleSuccess)
                }
            })
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
    
    func openTagList() {
        
        if let entity = self.displayEntry {
            let vc: SimpleListViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SimpleListVC") as! SimpleListViewController
            vc.items = entity.toTagList()
            vc.title = "タグリスト"
            vc.swipableCell = false
            vc.tapCallback = {(vc: SimpleListViewController, index: Int) -> Void in
                // タグで検索
                let selectedTag: String = vc.items[index]
                vc.dismissGridMenuAnimated(true, completion: { () -> Void in
                    let searchVC: EntryCollectionViewController = self.storyboard?.instantiateViewControllerWithIdentifier("EntryCollectionVC") as! EntryCollectionViewController
                    searchVC.title = "タグ：" + selectedTag
                    searchVC.query = "tag:" + selectedTag
                    NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PushViewController.rawValue, object: searchVC)
                })
            }
            NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PresentedViewController.rawValue, object: vc)
        }
    }
    
}
