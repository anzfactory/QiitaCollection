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
    var navButtonFollowing: SelectedBarButton? = nil
    var showAuthenticatedUser: Bool = false
    var displayUserId: String?
    var displayUser: UserEntity? = nil {
        didSet {
            self.title = displayUser?.displayName
        }
    }
    let qiitaManager: QiitaApiManager = QiitaApiManager.sharedInstance
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
        
        if self.showAuthenticatedUser || self.displayUserId == UserDataManager.sharedInstance.qiitaAuthenticatedUserID {
            return items
        }
        
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
        
        // キャプチャ
        let _afterDidLoad = self.afterDidLoad
        
        let completion: (item: UserEntity?, isError: Bool) -> Void = {(item, isError) -> Void in
            
            NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.HideLoading.rawValue, object: nil);
            
            if isError {
                Toast.show("ユーザーデータを取得できませんでした…", style: JFMinimalNotificationStytle.StyleWarning)
                return
            }
            
            self.displayUser = item!
            self.displayUserId = self.displayUser!.id
            self.userInfoContainer.showUser(self.displayUser!)
            
            if !self.showAuthenticatedUser && self.displayUser!.canFollow() {
                // フォローするnavigationの表示
                self.setupNavigationBar()
                // フォロー状況を取得
                self.getFollowingState()
            }
            
            if _afterDidLoad {
                self.entryListVC.refresh()
            }
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.ShowLoading.rawValue, object: nil);
        
        if let userId = self.displayUserId {
            self.qiitaManager.getUser(userId, completion:completion)
        } else if self.showAuthenticatedUser {
            self.qiitaManager.getAuthenticatedUser(completion)
        } else {
            fatalError("unknown user......")
        }
    }
    
    func setupNavigationBar() {
        self.navButtonFollowing = SelectedBarButton(image: UIImage(named: "bar_item_heart"), style: UIBarButtonItemStyle.Bordered, target: self, action: "confirmFollowing")
        self.navButtonFollowing!.selectedColor = UIColor.tintSelectedFollowingBarButton()
        self.navigationItem.rightBarButtonItem = self.navButtonFollowing
    }
    
    func makeEntryListVC() -> EntryListViewController {
        let vc: EntryListViewController = self.storyboard?.instantiateViewControllerWithIdentifier("EntryListVC") as EntryListViewController
        vc.displayItem = EntryListViewController.DisplayItem(type: EntryListViewController.ListType.UserEntries, self.displayUserId!)
        
        self.listContainer.addSubview(vc.view)
        vc.view.addConstraintFill()
        vc.viewWillAppear(false)
        
        return vc
    }
    
    func getFollowingState() {
        self.displayUser?.isFollowing({ (isFollowing) -> Void in
            self.navButtonFollowing?.selected = isFollowing
            return
        })
    }
    
    func confirmFollowing() {
        
        var message: String = ""
        
        if self.navButtonFollowing!.selected {
            message = "フォローを解除しますか？"
        } else {
            message = "フォローしますか？"
        }
        
        // アラート表示
        let action: SCLActionBlock = {() -> Void in
            self.toggleFollowing()
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.ShowAlertYesNo.rawValue, object: nil, userInfo: [
            QCKeys.AlertView.Title.rawValue: "確認",
            QCKeys.AlertView.Message.rawValue: message,
            QCKeys.AlertView.NoTitle.rawValue: "Cancel",
            QCKeys.AlertView.YesAction.rawValue: AlertViewSender(action: action, title: "OK")
        ])
    }
    
    func confirmAddedMuteUser() {
        
        if self.showAuthenticatedUser || UserDataManager.sharedInstance.qiitaAuthenticatedUserID == self.displayUserId {
            Toast.show("自分自身をミュートリストに…はちょっと…", style: JFMinimalNotificationStytle.StyleWarning)
            return
        }
        
        
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
    
    func toggleFollowing() {
        
        let completion = {(isError: Bool) -> Void in
            
            if isError {
                Toast.show("処理に失敗しました...", style: JFMinimalNotificationStytle.StyleError)
                return
            }
            
            self.getFollowingState()
            return
        }
        
        if self.navButtonFollowing!.selected {
            // 解除処理
            self.displayUser?.cancelFollowing(completion)
        } else {
            // フォロー処理
            self.displayUser?.follow(completion)
        }
        
    }

    // MARK: UserDetailViewDelegate
    func userDetailView(view: UserDetailView, sender: UIButton) {
        
        if self.displayUser == nil {
            return;
        }
        
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
