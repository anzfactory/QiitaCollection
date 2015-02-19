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
    @IBOutlet weak var listSwitchContainer: UIView!
    @IBOutlet weak var triggerListType: UISegmentedControl!
    
    // MARK: プロパティ
    var displayUserId: String?
    var displayUser: UserEntity? = nil {
        didSet {
            self.title = displayUser?.displayName
        }
    }
    let qiitaManager: QiitaApiManager = QiitaApiManager()
    lazy var entryListVC: EntryListViewController = self.makeEntryListVC()
    
    // MARK: ライフサイクル
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userInfoContainer.delegate = self
        self.listSwitchContainer.backgroundColor = UIColor.backgroundUserInfo()
        self.triggerListType.tintColor = UIColor.tintSegmented()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.listContainer.addSubview(self.entryListVC.view)
        entryListVC.view.addConstraintFill()
        self.entryListVC.viewWillAppear(false)
        
        self.refreshUser()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Actions
    @IBAction func changeTrigger(sender: AnyObject) {
        switch self.triggerListType.selectedSegmentIndex {
        case 0:
            self.entryListVC.displayItem = EntryListViewController.DisplayItem(type: EntryListViewController.ListType.UserEntries, self.displayUserId!)
        case 1:
            self.entryListVC.displayItem = EntryListViewController.DisplayItem(type: EntryListViewController.ListType.UserStocks, self.displayUserId!)
        default:
            return
        }
        self.entryListVC.refresh()
        
    }
    
    // MARK: メソッド
    func refreshUser() {
        
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.ShowLoading.rawValue, object: nil);
        
        self.qiitaManager.getUser(self.displayUserId!, completion: { (item, isError) -> Void in
            
            NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.HideLoading.rawValue, object: nil);
            
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
            
            self.entryListVC.refresh()
        })
    }
    
    func makeEntryListVC() -> EntryListViewController {
        let vc: EntryListViewController = self.storyboard?.instantiateViewControllerWithIdentifier("EntryListVC") as EntryListViewController
        vc.displayItem = EntryListViewController.DisplayItem(type: EntryListViewController.ListType.UserEntries, self.displayUserId!)
        return vc
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
