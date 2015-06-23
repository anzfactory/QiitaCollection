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
    
    // MARK: 制約
    @IBOutlet weak var userInfoContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var userInfoContainerMarginTop: NSLayoutConstraint!
    
    // MARK: プロパティ
    var navButtonFollowing: SelectedBarButton? = nil
    var showAuthenticatedUser: Bool = false
    var displayUserId: String?
    var displayAccount: OtherAccount? = nil
    
    lazy var entryListVC: EntryListViewController = self.makeEntryListVC()
    
    // MARK: ライフサイクル
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "ユーザー"
        self.userInfoContainer.delegate = self
        self.listSwitchContainer.backgroundColor = UIColor.backgroundUserInfo()
        self.triggerListType.tintColor = UIColor.tintSegmented()
        self.triggerListType.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(10)], forState: UIControlState.Normal)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupTriggerListType()
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
            if self.showAuthenticatedUser {
                self.entryListVC.displayItem = EntryListViewController.DisplayItem(type: EntryListViewController.ListType.AuthedEntries, self.displayUserId!)
            } else {
                self.entryListVC.displayItem = EntryListViewController.DisplayItem(type: EntryListViewController.ListType.UserEntries, self.displayUserId!)
            }
            
        case 1:
            self.entryListVC.displayItem = EntryListViewController.DisplayItem(type: EntryListViewController.ListType.UserStocks, self.displayUserId!)
        case 2:
            self.entryListVC.displayItem = EntryListViewController.DisplayItem(type: EntryListViewController.ListType.History, "")
        default:
            return
        }
        self.userInfoContainerMarginTop.constant = 0.0
        self.entryListVC.tableView.items.removeAll(keepCapacity: false)
        self.entryListVC.tableView.reloadData()
        self.entryListVC.refresh()
        
    }
    
    // MARK: メソッド
    override func publicMenuItems() -> [PathMenuItem] {
        
        var items: [PathMenuItem] = [PathMenuItem]()
        
        if self.showAuthenticatedUser || ((self.account is QiitaAccount) && (self.account as! QiitaAccount).isSelf(self.displayUserId!)) {
            return items
        }
        
        if self.account.existsMuteUser(self.displayUserId!) {
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
    
    func setupTriggerListType() {
        
        var items: [String] = [
            "投稿リスト",
            "ストックリスト",
        ]
        let selectedIndexOld = self.triggerListType.selectedSegmentIndex
        self.triggerListType.removeAllSegments()
        if self.showAuthenticatedUser {
            items.append("履歴リスト")
        }
        
        for var i: Int = 0; i < items.count; i++ {
            self.triggerListType.insertSegmentWithTitle(items[i], atIndex: i, animated: false)
        }
        
        if selectedIndexOld < items.count {
            self.triggerListType.selectedSegmentIndex = selectedIndexOld
        } else {
            self.triggerListType.selectedSegmentIndex = 1
        }
    }
    
    func refreshUser() {
        
        // キャプチャ
        let _afterDidLoad = self.afterDidLoad
        
        let completion: (item: UserEntity?) -> Void = {(item) -> Void in
            
            NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.HideLoadingWave.rawValue, object: nil);
            
            if let userEntity = item {
                
                self.displayUserId = userEntity.id
                self.userInfoContainer.showUser(userEntity)
                
                if !self.showAuthenticatedUser {
                    
                    if let qiitaAccount = self.account as? QiitaAccount {
                        
                        if qiitaAccount.canFollow(self.displayUserId!) {
                            // フォローするnavigationの表示
                            self.setupNavigationBar()
                            // フォロー状況を取得
                            self.getFollowingState()
                        }
                        
                    }
                    
                }
                if _afterDidLoad {
                    self.entryListVC.refresh()
                }
                
            } else {
                Toast.show("ユーザーデータを取得できませんでした…", style: JFMinimalNotificationStytle.StyleWarning)
            }
            
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.ShowLoadingWave.rawValue, object: nil);
        
        if self.showAuthenticatedUser {
            if let qiitaAccount = self.account as? QiitaAccount {
                self.displayAccount = qiitaAccount
            } else {
                fatalError("認証ユーザーがみつかりません...")
            }
        } else if let userId = self.displayUserId {
            self.displayAccount = OtherAccount(qiitaId: userId)
        } else {
            fatalError("不明なユーザー...")
        }
        
        self.displayAccount!.sync(completion)
        
    }
    
    func setupNavigationBar() {
        self.navButtonFollowing = SelectedBarButton(image: UIImage(named: "bar_item_heart"), style: UIBarButtonItemStyle.Plain, target: self, action: "confirmFollowing")
        self.navButtonFollowing!.selectedColor = UIColor.tintSelectedFollowingBarButton()
        self.navigationItem.rightBarButtonItem = self.navButtonFollowing
    }
    
    func makeEntryListVC() -> EntryListViewController {
        let vc: EntryListViewController = self.storyboard?.instantiateViewControllerWithIdentifier("EntryListVC") as! EntryListViewController

        if self.showAuthenticatedUser {
            vc.displayItem = EntryListViewController.DisplayItem(type: EntryListViewController.ListType.AuthedEntries, self.displayUserId!)
        } else {
            vc.displayItem = EntryListViewController.DisplayItem(type: EntryListViewController.ListType.UserEntries, self.displayUserId!)
        }
        
        self.listContainer.addSubview(vc.view)
        vc.view.addConstraintFill()
        vc.viewWillAppear(false)
        
        vc.observerScrollOffset = {(y, isBounce) -> Void in
            if y <= 0.0 {
                self.userInfoContainerMarginTop.constant = 0.0
                return
            } else if y > self.userInfoContainerHeight.constant || isBounce {
                return
            }
            
            self.userInfoContainerMarginTop.constant = y * -1.0
        }
        
        return vc
    }
    
    func getFollowingState() {
        
        if let qiitaAccount = self.account as? QiitaAccount {
            qiitaAccount.isFollowed(self.displayUserId!, completion: { (followed) -> Void in
                self.navButtonFollowing?.selected = followed
                return
            })
        }
        
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
        
        if self.showAuthenticatedUser || ((self.account is QiitaAccount) && (self.account as! QiitaAccount).isSelf(self.displayUserId!)) {
            Toast.show("自分自身をミュートリストに…はちょっと…", style: JFMinimalNotificationStytle.StyleWarning)
            return
        }
        
        // アラート表示
        let action: SCLActionBlock = {() -> Void in
            self.account.mute(self.displayUserId!)
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
            self.account.cancelMuteUser(self.displayUserId!)
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
        
        if let qiitaAccount = self.account as? QiitaAccount {
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
                qiitaAccount.cancelFollow(self.displayUserId!, completion: completion)
            } else {
                // フォロー処理
                qiitaAccount.follow(self.displayUserId!, completion: completion)
            }
        }
        
    }

    // MARK: UserDetailViewDelegate
    func userDetailView(view: UserDetailView, sender: UIButton) {
        
        if let entity = self.displayAccount?.entity {
            var urlString: String = ""
            if sender == view.website && !entity.web.isEmpty {
                urlString = entity.web
            } else if sender == view.github && !entity.github.isEmpty {
                urlString = "https://github.com/" + entity.github
            } else if sender == view.twitter && !entity.twitter.isEmpty {
                urlString = "https://twitter.com/" + entity.twitter
            } else if sender == view.facebook && !entity.facebook.isEmpty {
                urlString = "https://www.facebook.com/" + entity.facebook
            } else if sender == view.linkedin && !entity.linkedin.isEmpty {
                urlString = "https://www.linkedin.com/in/" + entity.linkedin
            }
            
            if urlString.isEmpty {
                return
            }
            
            var url: NSURL = NSURL(string: urlString)!
            UIApplication.sharedApplication().openURL(url)
        }
        
    }
}
