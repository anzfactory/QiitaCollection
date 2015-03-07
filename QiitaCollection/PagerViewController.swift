//
//  PagerViewController.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/09.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

// selectionHandlerにセットすると自動でよばれてしまって使いづらいので…
class QCGridMenuItem: CNPGridMenuItem {
    
    typealias TapAction = () -> Void
    var action: TapAction? = nil
    
}

class PagerViewController: ViewPagerController, ViewPagerDelegate, ViewPagerDataSource, CNPGridMenuDelegate {
    
    typealias ViewPagerItem = (title:String, identifier:String, query:String)

    // MARK: プロパティ
    var leftBarItem: UIBarButtonItem?
    var viewPagerItems: [ViewPagerItem] = [ViewPagerItem]()
    lazy var menu: CNPGridMenu = self.makeMenu()
    var reloadViewPager: Bool = false
    var viewPagerTabWidth: CGFloat = 120.0
    var viewPagerTabHeight: CGFloat = 0.0
 
    // MARK: ライフサイクル
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "(ﾟ∀ﾟ)ｷﾀｺﾚ!!"
        
        let rightButtons: [UIBarButtonItem] = [
            UIBarButtonItem(image: UIImage(named: "bar_item_setting"), style: UIBarButtonItemStyle.Plain, target: self, action: "tapSetting"),
            UIBarButtonItem(image: UIImage(named: "bar_item_search"), style: UIBarButtonItemStyle.Plain, target: self, action: "tapSearch")
        ]
        self.navigationItem.rightBarButtonItems = rightButtons
        rightButtons[1].showGuide(GuideManager.GuideType.SearchIcon)
        
        self.setupViewControllers()
        
        // デフォルトVC
        self.dataSource = self
        self.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receiveReloadViewPager", name: QCKeys.Notification.ReloadViewPager.rawValue, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.reloadViewPager {
            self.reloadViewPager = false
            self.setupViewControllers()
            self.reloadData()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: メソッド
    func setupViewControllers() {
        self.viewPagerItems.removeAll(keepCapacity: false)
        self.viewPagerItems.append(ViewPagerItem(title: "新着", identifier:"EntryCollectionVC", query:""))
        
        // クエリで回す
        let queries: [[String: String]] = UserDataManager.sharedInstance.queries
        if !queries.isEmpty {
            for queryItem in queries {
                self.viewPagerItems.append(ViewPagerItem(title: queryItem["title"]!, identifier:"EntryCollectionVC", query:queryItem["query"]!))
            }
        }
        
        // 保存した投稿リストがあるか
        if !UserDataManager.sharedInstance.entryFiles.isEmpty {
            self.viewPagerItems.append(ViewPagerItem(title:"保存した投稿", identifier:"SimpleListVC", query: ""))
        }
        
        // 認証済みなら末尾にmypage
        if UserDataManager.sharedInstance.isAuthorizedQiita() {
            self.viewPagerItems.append(ViewPagerItem(title:"マイページ", identifier:"UserDetailVC", query:""))
        }
        
        let width: CGFloat = self.view.frame.size.width / CGFloat(self.viewPagerItems.count)
        if width > 120.0 {
            self.viewPagerTabWidth = width
        } else {
            self.viewPagerTabWidth = 120.0
        }

    }
    func makeMenu() -> CNPGridMenu {
        let menuItemMuteUsers: QCGridMenuItem = QCGridMenuItem()
        menuItemMuteUsers.icon = UIImage(named: "icon_circle_slash")
        menuItemMuteUsers.title = "Mute User"
        menuItemMuteUsers.action = {(item) -> Void in
            self.openMuteUserList()
            return
        }
        
        let menuItemPinEntries: QCGridMenuItem = QCGridMenuItem()
        menuItemPinEntries.icon = UIImage(named: "icon_pin")
        menuItemPinEntries.title = "Pins"
        menuItemPinEntries.action = {(item) -> Void in
            self.openPinEntryList()
            return
        }
        
        let menuItemQuery: QCGridMenuItem = QCGridMenuItem()
        menuItemQuery.icon = UIImage(named: "icon_lock")
        menuItemQuery.title = "Query"
        menuItemQuery.action = {(item) -> Void in
            self.openQueryList()
        }
        
        let menuItemSigin: QCGridMenuItem = QCGridMenuItem()
        if UserDataManager.sharedInstance.isAuthorizedQiita() {
            menuItemSigin.icon = UIImage(named: "icon_sign_out")
            menuItemSigin.title = "Sign out"
            menuItemSigin.action = {(item) -> Void in
                self.confirmSignout()
            }
        } else {
            menuItemSigin.icon = UIImage(named: "icon_sign_in")
            menuItemSigin.title = "Sign in"
            menuItemSigin.action = {(item) -> Void in
                self.openSigninVC()
            }
        }
        
        
        let menuItemInfo: QCGridMenuItem = QCGridMenuItem()
        menuItemInfo.icon = UIImage(named: "icon_info")
        menuItemInfo.title = "About App"
        menuItemInfo.action = {(item) -> Void in
            self.openAboutApp()
        }
        
        let menu: CNPGridMenu = CNPGridMenu(menuItems: [menuItemMuteUsers, menuItemPinEntries, menuItemQuery, menuItemSigin, menuItemInfo])
        menu.delegate = self
        return menu
    }
    
    func tapSetting() {

        self.presentGridMenu(self.menu, animated: true) { () -> Void in
            
        }
    }
    
    func tapSearch() {
        let vc: SearchViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SearchVC") as SearchViewController
        vc.callback = {(searchVC: SearchViewController, q: String) -> Void in
            
            let entriesVC: EntryCollectionViewController = self.storyboard?.instantiateViewControllerWithIdentifier("EntryCollectionVC") as EntryCollectionViewController
            entriesVC.query = q
            entriesVC.title = "検索結果"
            NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PushViewController.rawValue, object: entriesVC)
            
            searchVC.dismissViewControllerAnimated(true, completion: { () -> Void in
                
            })
            
        }
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PresentedViewController.rawValue, object: vc)
    }
    
    func openMuteUserList() {
        
        let mutedUsers: [String] = UserDataManager.sharedInstance.muteUsers
        if (mutedUsers.isEmpty) {
            Toast.show("ミュートユーザーが追加されていません", style: JFMinimalNotificationStytle.StyleInfo)
            return
        }
        
        let muteVC: SimpleListViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SimpleListVC") as SimpleListViewController
        muteVC.items = UserDataManager.sharedInstance.muteUsers
        muteVC.title = "ミュートリスト"
        muteVC.cellGuide = GuideManager.GuideType.MuteListSwaipeCell
        muteVC.tapCallback = {(vc: SimpleListViewController, index: Int) -> Void in
            
            // まずは閉じる
            vc.dismissViewControllerAnimated(true, completion: { () -> Void in
                // user詳細
                let userVC: UserDetailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("UserDetailVC") as UserDetailViewController
                userVC.displayUserId = UserDataManager.sharedInstance.muteUsers[index]
                NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PushViewController.rawValue, object: userVC)
            })
            
        }
        muteVC.swipeCellCallback = {(vc: SimpleListViewController, cell: SlideTableViewCell, index:Int) -> Void in
            UserDataManager.sharedInstance.clearMutedUser(vc.items[cell.tag])
            vc.removeItem(index)
            Toast.show("ミュートを解除しました", style: JFMinimalNotificationStytle.StyleSuccess, title: "", targetView: vc.view)
        }
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PresentedViewController.rawValue, object: muteVC)
    }
    
    func openPinEntryList() {
        
        let pinEntries: [[String: String]] = UserDataManager.sharedInstance.pins
        if (pinEntries.isEmpty) {
            Toast.show("pinした投稿がありません", style: JFMinimalNotificationStytle.StyleInfo)
            return
        }
        
        // 渡すようのリストをつくる
        var pins: [String] = Array<String>.convert(pinEntries, key: "title")
        
        let vc: SimpleListViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SimpleListVC") as SimpleListViewController
        vc.items = pins
        vc.title = "pinリスト"
        vc.cellGuide = GuideManager.GuideType.PinListSwaipeCell
        vc.tapCallback = {(vc: SimpleListViewController, index: Int) -> Void in
            
            // まずは閉じる
            vc.dismissViewControllerAnimated(true, completion: { () -> Void in
                // 記事詳細
                let entryVC: EntryDetailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("EntryDetailVC") as EntryDetailViewController
                entryVC.displayEntryId = UserDataManager.sharedInstance.pins[index]["id"]
                NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PushViewController.rawValue, object: entryVC)
            })
            
        }
        vc.swipeCellCallback = {(vc: SimpleListViewController, cell: SlideTableViewCell, index: Int) -> Void in
            UserDataManager.sharedInstance.clearPinEntry(index)
            // 再作成
            vc.removeItem(index)
            Toast.show("pinした投稿を解除しました", style: JFMinimalNotificationStytle.StyleSuccess, title: "", targetView: vc.view)
        }
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PresentedViewController.rawValue, object: vc)
        
    }
    
    func openQueryList() {
        let queries: [[String: String]] = UserDataManager.sharedInstance.queries
        
        if queries.isEmpty {
            Toast.show("保存した検索がありません...", style: JFMinimalNotificationStytle.StyleInfo)
            return
        }
        
        let queryLabels: [String] = [String].convert(queries, key: "title")
        
        let vc: SimpleListViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SimpleListVC") as SimpleListViewController
        vc.items = queryLabels
        vc.title = "保存した検索条件"
        vc.cellGuide = GuideManager.GuideType.QueryListSwipeCell
        vc.tapCallback = {(vc: SimpleListViewController, index: Int) -> Void in
            // 特に何もしない
        }
        vc.swipeCellCallback = {(vc: SimpleListViewController, cell: SlideTableViewCell, index: Int) -> Void in
            // 削除処理
            UserDataManager.sharedInstance.clearQuery(index)
            // ViewPager再構成
            self.setupViewControllers()
            self.reloadData()
            vc.dismissViewControllerAnimated(true, completion: { () -> Void in
                
            })
            return
        }
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PresentedViewController.rawValue, object: vc)
    }
    
    func openSigninVC() {
        let vc: SigninViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SigninVC") as SigninViewController
        vc.authorizationAction = {(viewController: SigninViewController) -> Void in
            QiitaApiManager.sharedInstance.setupHeader()    // ヘッダーに認証情報を含めるよう指示
            // ViewPager再構成
            self.menu = self.makeMenu()
            self.setupViewControllers()
            self.reloadData()
            // 認証ユーザーの情報を取ってIDだけ保持しておく (self判定したいんで...)
            QiitaApiManager.sharedInstance.getAuthenticatedUser({ (item, isError) -> Void in
                if isError {
                    return
                }
                UserDataManager.sharedInstance.qiitaAuthenticatedUserID = item!.id
                return
            })
            viewController.dismissViewControllerAnimated(true, completion: { () -> Void in
                
            })
            return
        }
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PresentedViewController.rawValue, object: vc)
    }
    
    func openAboutApp() {
        let vc: AboutAppViewController = self.storyboard?.instantiateViewControllerWithIdentifier("AboutAppVC") as AboutAppViewController
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PresentedViewController.rawValue, object: vc)
    }
    
    func confirmSignout() {
        let actionDestructive: UIAlertAction = UIAlertAction(title: "Sign Out", style: UIAlertActionStyle.Destructive) { (action) -> Void in
            
            QiitaApiManager.sharedInstance.deleteAccessToken(UserDataManager.sharedInstance.qiitaAccessToken, completion: { (isError) -> Void in
                if isError {
                    Toast.show("サインアウトに失敗しました…", style: JFMinimalNotificationStytle.StyleError)
                    return
                }
                
                QiitaApiManager.sharedInstance.clearHeader()
                UserDataManager.sharedInstance.clearQiitaAccessToken()
                
                self.menu = self.makeMenu()
                self.setupViewControllers()
                self.reloadData()
                
            })
            
        }
        
        let actionCancel: UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action) -> Void in
            
        }
        
        let args = [
            QCKeys.AlertController.Style.rawValue      : UIAlertControllerStyle.Alert.rawValue,
            QCKeys.AlertController.Title.rawValue      : "確認",
            QCKeys.AlertController.Description.rawValue: "サインアウトしてしまうとリクエスト制限が厳しくなりますが本当によろしいですか？",
            QCKeys.AlertController.Actions.rawValue    : [
                actionDestructive,
                actionCancel
            ]
        ]
        
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.ShowAlertController.rawValue, object: self, userInfo: args)
        
    }
    
    // MARK: NSNotification
    func receiveReloadViewPager() {
        self.reloadViewPager = true
    }
    
    // MARK: ViewPagerDatasource
    func numberOfTabsForViewPager(viewPager: ViewPagerController!) -> UInt {
        return UInt(self.viewPagerItems.count)
    }
    func viewPager(viewPager: ViewPagerController!, viewForTabAtIndex index: UInt) -> UIView! {
        let current: ViewPagerItem = self.viewPagerItems[Int(index)]
        
        let title: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.viewPagerTabWidth, height: self.viewPagerTabHeight))
        title.text = current.title
        title.font = UIFont.boldSystemFontOfSize(14.0)
        title.textColor = UIColor.textBase()
        title.lineBreakMode = NSLineBreakMode.ByTruncatingMiddle
        title.textAlignment = NSTextAlignment.Center
        return title
    }
    func viewPager(viewPager: ViewPagerController!, contentViewControllerForTabAtIndex index: UInt) -> UIViewController! {
        
        let current: ViewPagerItem = self.viewPagerItems[Int(index)]
        let vc: UIViewController = self.storyboard?.instantiateViewControllerWithIdentifier(current.identifier) as UIViewController
        
        if vc is EntryCollectionViewController {
            (vc as EntryCollectionViewController).query = current.query
        } else if vc is SimpleListViewController {
            let simpleVC: SimpleListViewController = vc as SimpleListViewController
            var items: [String] = [String]()
            for entryFile in UserDataManager.sharedInstance.entryFiles {
                items.append(entryFile["title"]!)
            }
            simpleVC.removeNavigationBar = true
            simpleVC.items = items
            simpleVC.swipableCell = false
            simpleVC.tapCallback = {(vc:SimpleListViewController, index:Int) -> Void in
                
                let item: [String: String] = UserDataManager.sharedInstance.entryFiles[index]
                let entryDetail: EntryDetailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("EntryDetailVC") as EntryDetailViewController
                entryDetail.displayEntryId = item["id"]
                entryDetail.useLocalFile = true
                NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PushViewController.rawValue, object: entryDetail)
                
            }
        } else if vc is UserDetailViewController {
            (vc as UserDetailViewController).showAuthenticatedUser = true
        }
        return vc
    }
    
    // MARK: ViewPagerDelegate
    func viewPager(viewPager: ViewPagerController!, colorForComponent component: ViewPagerComponent, withDefault color: UIColor!) -> UIColor! {
        switch component {
        case ViewPagerComponent.TabsView:
            return UIColor.backgroundPagerTab()
        case ViewPagerComponent.Indicator:
            return UIColor.backgroundAccent()
        default:
            return color
        }
    }
    
    func viewPager(viewPager: ViewPagerController!, valueForOption option: ViewPagerOption, withDefault value: CGFloat) -> CGFloat {
        switch option {
        case ViewPagerOption.CenterCurrentTab:
            return 1.0
        case ViewPagerOption.TabWidth:
            return self.viewPagerTabWidth
        case ViewPagerOption.TabHeight:
            // デフォルト値を保持したいだけなのでスルーさせる
            self.viewPagerTabHeight = value
            fallthrough
        default:
            return value
        }
    }
    
    // MARK: CNPGridMenuDelegate
    func gridMenu(menu: CNPGridMenu!, didTapOnItem item: CNPGridMenuItem!) {
        menu.dismissGridMenuAnimated(true, completion: { () -> Void in
            let qcitem = item as QCGridMenuItem
            qcitem.action?()
            return
        })
    }
    
    func gridMenuDidTapOnBackground(menu: CNPGridMenu!) {
        menu.dismissGridMenuAnimated(true, completion: { () -> Void in
            
        })
    }
    
}
