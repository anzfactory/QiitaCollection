//
//  PagerViewController.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/09.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class PagerViewController: BaseViewController {

    // MARK: プロパティ
    var leftBarItem: UIBarButtonItem?
    var pageMenu : CAPSPageMenu!
    var controllerArray : [UIViewController] = []
    lazy var menu: REMenu = self.makeMenu()
    
    // MARK: ライフサイクル
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "(ﾟ∀ﾟ)ｷﾀｺﾚ!!"
        
        let rightButtons: [UIBarButtonItem] = [
            UIBarButtonItem(image: UIImage(named: "icon_setting"), style: UIBarButtonItemStyle.Plain, target: self, action: "tapSetting"),
            UIBarButtonItem(image: UIImage(named: "icon_search"), style: UIBarButtonItemStyle.Plain, target: self, action: "tapSearch")
        ]
        self.navigationItem.rightBarButtonItems = rightButtons
        
        let vc : UIViewController = self.storyboard?.instantiateViewControllerWithIdentifier("EntryCollectionVC") as UIViewController
        vc.title = "新着"
        controllerArray.append(vc)
        
        var parameters: [String: AnyObject] = ["menuItemSeparatorWidth": 4.3,
            "useMenuLikeSegmentedControl": true,
            "menuItemSeparatorPercentageHeight": 0.1,
            "bottomMenuHairlineColor" : UIColor.borderPageMenuIndicator(),
            "selectionIndicatorColor" : UIColor.borderPageMenuIndicator(),
            "selectedMenuItemLabelColor" : UIColor.textPageMenuLabel(),
            "unselectedMenuItemLabelColor" : UIColor.textPageMenuLabel(),
            "menuItemFont" : UIFont.boldSystemFontOfSize(14.0)]
        
        self.pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRectMake(0.0, 0.0, self.view.frame.width, self.view.frame.height), options: parameters)
        self.view.addSubview(self.pageMenu!.view)

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.pageMenu.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.pageMenu.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: メソッド
    func makeMenu() -> REMenu {
        let menuItemMuteUsers: REMenuItem = REMenuItem(title: "ミュートリスト", image: nil, highlightedImage: nil) { (menuItem) -> Void in
            self.openMuteUserList()
        }
        let menu: REMenu = REMenu(items: [menuItemMuteUsers])
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
        
        let vc: SimpleListViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SimpleListVC") as SimpleListViewController
        vc.items = UserDataManager.sharedInstance.muteUsers
        vc.title = "ミュートリスト"
        vc.tapCallback = {(vc: SimpleListViewController, index: Int) -> Void in
            
            // まずは閉じる
            vc.dismissViewControllerAnimated(true, completion: { () -> Void in
                // user詳細
                let userVC: UserDetailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("UserDetailVC") as UserDetailViewController
                userVC.displayUserId = mutedUsers[index]
                NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PushViewController.rawValue, object: userVC)
            })
            
        }
        let nc: UINavigationController = self.storyboard?.instantiateViewControllerWithIdentifier("BlankNC") as UINavigationController
        nc.setViewControllers([vc], animated: false)
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PresentedViewController.rawValue, object: nc)
    }

}
