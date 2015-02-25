//
//  PagerViewController.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/09.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class PagerViewController: ViewPagerController, ViewPagerDelegate, ViewPagerDataSource {
    
    typealias ViewPagerItem = (title:String, identifier:String, query:String)

    // MARK: プロパティ
    var leftBarItem: UIBarButtonItem?
    var viewPagerItems: [ViewPagerItem] = [ViewPagerItem]()
    lazy var menu: REMenu = self.makeMenu()
    var reloadViewPager: Bool = false
 
    // MARK: ライフサイクル
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "(ﾟ∀ﾟ)ｷﾀｺﾚ!!"
        
        let rightButtons: [UIBarButtonItem] = [
            UIBarButtonItem(image: UIImage(named: "icon_setting"), style: UIBarButtonItemStyle.Plain, target: self, action: "tapSetting"),
            UIBarButtonItem(image: UIImage(named: "icon_search"), style: UIBarButtonItemStyle.Plain, target: self, action: "tapSearch")
        ]
        self.navigationItem.rightBarButtonItems = rightButtons
        
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
        let queries: [String: String] = UserDataManager.sharedInstance.queries
        if !queries.isEmpty {
            for query in queries {
                let queryVC : EntryCollectionViewController = self.storyboard?.instantiateViewControllerWithIdentifier("EntryCollectionVC") as EntryCollectionViewController
                self.viewPagerItems.append(ViewPagerItem(title: query.1, identifier:"EntryCollectionVC", query:query.0))
            }
        }

    }
    func makeMenu() -> REMenu {
        let menuItemMuteUsers: REMenuItem = REMenuItem(title: "ミュートリスト", image: nil, highlightedImage: nil) { (menuItem) -> Void in
            self.openMuteUserList()
        }
        let menuItemPinEntries: REMenuItem = REMenuItem(title: "pin投稿リスト", image: nil, highlightedImage: nil) { (menuItem) -> Void in
            self.openPinEntryList()
        }
        let menu: REMenu = REMenu(items: [menuItemMuteUsers, menuItemPinEntries])
        menu.backgroundColor = UIColor.backgroundNavigationMenu()
        menu.textColor = UIColor.textNavigationBar()
        menu.highlightedBackgroundColor = UIColor.backgroundBase()
        menu.borderWidth = 0
        menu.separatorHeight = 0.5
        menu.separatorColor = UIColor.borderNavigationMenuSeparator()
        menu.highlightedTextColor = UIColor.textNavigationBar()
        menu.font = UIFont.boldSystemFontOfSize(12.0)
        return menu
    }
    
    func tapSetting() {
        
        if self.menu.isOpen {
            self.menu.close()
            return
        }
        
        self.menu.showFromNavigationController(self.navigationController)
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
        
        let vc: MuteListViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MuteListVC") as MuteListViewController
        vc.items = UserDataManager.sharedInstance.muteUsers
        vc.title = "ミュートリスト"
        vc.tapCallback = {(vc: SimpleListViewController, index: Int) -> Void in
            
            // まずは閉じる
            vc.dismissViewControllerAnimated(true, completion: { () -> Void in
                // user詳細
                let userVC: UserDetailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("UserDetailVC") as UserDetailViewController
                userVC.displayUserId = UserDataManager.sharedInstance.muteUsers[index]
                NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PushViewController.rawValue, object: userVC)
            })
            
        }
        let nc: UINavigationController = self.storyboard?.instantiateViewControllerWithIdentifier("BlankNC") as UINavigationController
        nc.setViewControllers([vc], animated: false)
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PresentedViewController.rawValue, object: nc)
    }
    
    func openPinEntryList() {
        
        let pinEntries: [[String: String]] = UserDataManager.sharedInstance.pins
        if (pinEntries.isEmpty) {
            Toast.show("pinした投稿がありません", style: JFMinimalNotificationStytle.StyleInfo)
            return
        }
        
        // 渡すようのリストをつくる
        var pins: [String] = [String]()
        for pinEntry in pinEntries {
            if let title = pinEntry["title"] {
                pins.append(title)
            }
            
        }
        
        let vc: PinListViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PinListVC") as PinListViewController
        vc.items = pins
        vc.title = "pinリスト"
        vc.tapCallback = {(vc: SimpleListViewController, index: Int) -> Void in
            
            // まずは閉じる
            vc.dismissViewControllerAnimated(true, completion: { () -> Void in
                // 記事詳細
                let entryVC: EntryDetailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("EntryDetailVC") as EntryDetailViewController
                entryVC.displayEntryId = UserDataManager.sharedInstance.pins[index]["id"]
                NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PushViewController.rawValue, object: entryVC)
            })
            
        }
        let nc: UINavigationController = self.storyboard?.instantiateViewControllerWithIdentifier("BlankNC") as UINavigationController
        nc.setViewControllers([vc], animated: false)
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PresentedViewController.rawValue, object: nc)
        
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
        
        let title: UILabel = UILabel(frame: CGRectZero)
        title.text = current.title
        title.font = UIFont.boldSystemFontOfSize(14.0)
        title.textColor = UIColor.textBase()
        title.sizeToFit()
        return title
    }
    func viewPager(viewPager: ViewPagerController!, contentViewControllerForTabAtIndex index: UInt) -> UIViewController! {
        let current: ViewPagerItem = self.viewPagerItems[Int(index)]
        let vc: UIViewController = self.storyboard?.instantiateViewControllerWithIdentifier(current.identifier) as UIViewController
        if vc is EntryCollectionViewController {
            (vc as EntryCollectionViewController).query = current.query
        }
        return vc
    }
    
    // MARK: ViewPagerDelegate
    func viewPager(viewPager: ViewPagerController!, colorForComponent component: ViewPagerComponent, withDefault color: UIColor!) -> UIColor! {
        switch component {
        case ViewPagerComponent.TabsView:
            return UIColor.backgroundPagerTab()
        case ViewPagerComponent.Indicator:
            return UIColor.backgroundSub()
        default:
            return color
        }
    }
    
}
