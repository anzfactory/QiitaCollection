//
//  UserDetailViewController.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/15.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class UserDetailViewController: UIViewController, UserDetailViewDelegate {

    // MARK: UI
    @IBOutlet weak var userInfoContainer: UserDetailView!
    @IBOutlet weak var listContainer: UIView!
    
    // MARK: プロパティ
    lazy var pageMenu: CAPSPageMenu = self.makePageMenu()
    var displayUserId: String?
    var displayUser: UserEntity? = nil {
        didSet {
            self.title = displayUser?.displayName
        }
    }
    let qiitaManager: QiitaApiManager = QiitaApiManager()
    
    // MARK: ライフサイクル
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userInfoContainer.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.qiitaManager.getUser(self.displayUserId!, completion: { (item, isError) -> Void in
            if isError {
                NSNotificationCenter.defaultCenter()
                    .postNotificationName(QCKeys.Notification.ShowMinimumNotification.rawValue,
                        object: nil,
                        userInfo: [
                            QCKeys.MinimumNotification.SubTitle.rawValue: "ユーザーデータを取得できませんでした…",
                            QCKeys.MinimumNotification.Style.rawValue: NSNumber(integer: JFMinimalNotificationStytle.StyleWarning.rawValue)
                        ])
                return
            }
            self.displayUser = item
            self.userInfoContainer.showUser(self.displayUser!)
        })
        
        self.listContainer.addSubview(self.pageMenu.view)
        self.pageMenu.view.layoutIfNeeded()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: メソッド
    func makePageMenu() -> CAPSPageMenu {
        
        let entryListVC: EntryListViewController = self.storyboard?.instantiateViewControllerWithIdentifier("EntryListVC") as EntryListViewController
        entryListVC.displayItem = EntryListViewController.DisplayItem(type: EntryListViewController.ListType.UserEntries, self.displayUserId!)
        
        var parameters: [String: AnyObject] = ["menuItemSeparatorWidth": 4.3,
            "useMenuLikeSegmentedControl": true,
            "menuItemSeparatorPercentageHeight": 0.1,
            "bottomMenuHairlineColor" : UIColor.borderPageMenuIndicator(),
            "selectionIndicatorColor" : UIColor.borderPageMenuIndicator(),
            "selectedMenuItemLabelColor" : UIColor.textPageMenuLabel(),
            "unselectedMenuItemLabelColor" : UIColor.textPageMenuLabel(),
            "menuItemFont" : UIFont.boldSystemFontOfSize(14.0)]
        
        return CAPSPageMenu(viewControllers: [entryListVC], frame: CGRectMake(0.0, 0.0, self.listContainer.frame.width, self.listContainer.frame.height), options: parameters)
    }
    
    // MARK: UserDetailViewDelegate
    func userDetailView(view: UserDetailView, sender: UIButton) {
        var urlString: String = ""
        if sender == view.website {
            urlString = self.displayUser!.web
        } else if sender == view.github && !self.displayUser!.github.isEmpty {
            urlString = "https://github.com/" + self.displayUser!.github
        } else if sender == view.twitter && !self.displayUser!.twitter.isEmpty {
            urlString = "https://twitter.com/" + self.displayUser!.twitter
        } else if sender == view.facebook && !self.displayUser!.facebook.isEmpty {
            urlString = "https://www.facebook.com/" + self.displayUser!.facebook
        } else if sender == view.linkedin && !self.displayUser!.linkedin.isEmpty {
            urlString = "https://www.linkedin.com/in/" + self.displayUser!.linkedin
        }
        
        if urlString.isEmpty {
            return
        }
        
        var url: NSURL = NSURL(string: urlString)!
        UIApplication.sharedApplication().openURL(url)
        
    }
}
