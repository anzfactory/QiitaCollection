//
//  UserDetailViewController.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/15.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class UserDetailViewController: BaseViewController, UserDetailViewDelegate {

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
    override func publicMenuItems() -> [PathMenuItem] {
        
        var items: [PathMenuItem] = [PathMenuItem]()
        if UserDataManager.sharedInstance.isMutedUser(self.displayUserId!) {
            let menuItemMute: QCPathMenuItem = QCPathMenuItem(mainImage: UIImage(named: "menu_eye")!)
            menuItemMute.action = {() -> Void in
                self.confirmClearMuted()
                return
            }
            items.append(menuItemMute)
        } else {
            let menuItemMute: QCPathMenuItem = QCPathMenuItem(mainImage: UIImage(named: "menu_circle_slash")!)
            menuItemMute.action = {() -> Void in
                self.confirmAddedMuteUser()
                return
            }
            items.append(menuItemMute)
        }
        
        
        return items

    }
    func refreshUser() {
        
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.ShowLoading.rawValue, object: nil);
        
        self.qiitaManager.getUser(self.displayUserId!, completion: { (item, isError) -> Void in
            
            NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.HideLoading.rawValue, object: nil);
            
            if isError {
                Toast.show("ユーザーデータを取得できませんでした…", style: JFMinimalNotificationStytle.StyleWarning)
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
    
    func confirmAddedMuteUser() {
        // TODO: 認証処理をくわえたら自身じゃないかちぇっく
        
        // アラート表示
        let action: SCLActionBlock = {() -> Void in
            UserDataManager.sharedInstance.appendMuteUserId(self.displayUserId!)
            Toast.show("ミュートユーザーに追加しました", style: JFMinimalNotificationStytle.StyleSuccess)
            NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.ResetPublicMenuItems.rawValue, object: self)
            return
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.ShowAlertYesNo.rawValue, object: nil, userInfo: [
            QCKeys.AlertView.Message.rawValue: "ミュートユーザーに入れると、すべての投稿リストから表示されなくなります\n本当に良いので？",
            QCKeys.AlertView.YesAction.rawValue: AlertViewSender(action: action, title: "追加する")
        ])
    }
    
    func confirmClearMuted() {
        let action: SCLActionBlock = {() -> Void in
            UserDataManager.sharedInstance.clearMutedUser(self.displayUserId!)
            Toast.show("ミュートを解除しました", style: JFMinimalNotificationStytle.StyleSuccess)
            NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.ResetPublicMenuItems.rawValue, object: self)
            return
        }
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.ShowAlertYesNo.rawValue, object: nil, userInfo: [
            QCKeys.AlertView.Message.rawValue: "ミュートを解除すると、投稿リストに表示されるようになります",
            QCKeys.AlertView.YesAction.rawValue: AlertViewSender(action: action, title: "解除する")
        ])
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
