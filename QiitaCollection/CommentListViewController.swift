//
//  CommentListViewController.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/28.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class CommentListViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    enum InputStatus {
        case
        None,
        Writing,
        Confirm
    }
    
    // MARK: UI
    @IBOutlet weak var tableView: BaseTableView!
    @IBOutlet weak var comment: UITextView!
    @IBOutlet weak var constraintCommentHeight: NSLayoutConstraint!
    
    // MARK: プロパティ
    var displayEntryId: String = ""
    var displayEntryTitle: String = ""
    var openTextView: Bool = false
    var inputStatus: InputStatus = .None
    var targetComment: CommentEntity? = nil
    
    // MARK: ライフサイクル
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.comment.backgroundColor = UIColor.backgroundSub()
        self.comment.textColor = UIColor.textBase()
        self.comment.hidden = true
        self.constraintCommentHeight.constant = 0.0
        
        self.title = "コメント"
        self.tableView.estimatedRowHeight = 104
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.setupRefreshControl { () -> Void in
            self.refresh()
        }
        
        self.setupNavigationBar()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receiveKeyboardShowNotification:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receiveKeyboardDidShowNotification:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receiveKeyboardHideNotification:", name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receiveKeyboardDidHideNotification:", name: UIKeyboardDidHideNotification, object: nil)
        
        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if !self.isBeingPresented() && !self.isMovingToParentViewController() {
            return
        }
        
        if self.displayEntryId.isEmpty {
            fatalError("required display entry id...")
        }
        
        self.refresh()
        
    }
    
    // MARK: メソッド
    func setupNavigationBar() {
        if self.openTextView {
            let edit: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "bar_item_check"), style: UIBarButtonItemStyle.Plain, target: self, action: "tapCheck")
            edit.tintColor = UIColor.tintAttention()
            self.navigationItem.rightBarButtonItem = edit
        } else {
            let edit: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "bar_item_pencil"), style: UIBarButtonItemStyle.Plain, target: self, action: "tapEdit")
            self.navigationItem.rightBarButtonItem = edit
        }
        
    }
    
    func refresh() {
        self.tableView.page = 1
        self.load()
    }
    
    func load() {
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.ShowLoadingWave.rawValue, object: nil)
        self.account.comments(self.tableView.page, entryId: self.displayEntryId) { (total, items) -> Void in
            if total == 0 {
                Toast.show("コメントが投稿されていません…", style: JFMinimalNotificationStytle.StyleInfo)
                // 1件しかなかったコメントを削除した場合はこっちにくるから、
                // クリアしょりをいれとく
                self.tableView.clearItems()
            } else {
                self.tableView.loadedItems(total, items: items, isAppendable: nil)
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.HideLoadingWave.rawValue, object: nil)
        }
        
    }
    
    func tapThumb(cell: CommentTableViewCell) {
        let entity: CommentEntity = self.tableView.items[cell.tag] as! CommentEntity
        let vc: UserDetailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("UserDetailVC") as! UserDetailViewController
        vc.displayUserId = entity.postUser.id
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PushViewController.rawValue, object: vc)
    }
    
    func tapEdit() {
        self.prepareComment("")
    }
    
    func tapCheck() {
        if !self.openTextView {
            return
        }
        self.inputStatus = .Confirm
        self.comment.resignFirstResponder()
    }
    
    func tapCommentEdit(cell: CommentTableViewCell) {
        
        if self.account is QiitaAccount == false {
            return
        }
        
        let entity: CommentEntity = self.tableView.items[cell.tag] as! CommentEntity
        
        if (self.account as! QiitaAccount).canCommentEdit(entity.postUser.id) == false {
            print("can not edit")
            return
        }
        
        // 編集なのか、削除なのか
        let params = [
            QCKeys.AlertController.Style.rawValue      : UIAlertControllerStyle.ActionSheet.rawValue,
            QCKeys.AlertController.Title.rawValue      : "選んで下さい",
            QCKeys.AlertController.Description.rawValue: "コメントを編集しますか？削除しますか？？",
            QCKeys.AlertController.Actions.rawValue    : [
                UIAlertAction(title: "編集", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                    self.prepareComment(entity.body)
                }),
                UIAlertAction(title: "削除", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                    self.confirmDeleteComment()
                }),
                UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
                    // なにもしない
                })
            ]
        ]
        
        self.targetComment = entity
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.ShowAlertController.rawValue, object: self, userInfo: params as [NSObject : AnyObject])
        
    }
    
    func prepareComment(defaultComment: String) {
        if self.openTextView {
            return
        }
        self.openTextView = true
        
        self.comment.text = defaultComment.removeExceptionUnicode()
        self.comment.becomeFirstResponder()
    }
    
    func openCommentField(keyboardHeight: CGFloat) {
        
        self.inputStatus = .Writing
        self.comment.hidden = false
        self.constraintCommentHeight.constant = self.tableView.bounds.size.height - keyboardHeight
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
        
    }
    
    func fullscreenComment() {
        self.constraintCommentHeight.constant = self.tableView.bounds.size.height
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    func dismissCommentField() {
        
        self.constraintCommentHeight.constant = 0.0
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }) { (finished) -> Void in
            self.comment.hidden = true
            self.inputStatus = .None
            self.openTextView = false
            self.setupNavigationBar()
        }
        
    }
    
    func postComment() {
        
        if let qiitaAccount = self.account as? QiitaAccount {
            if self.comment.text.isEmpty {
                Toast.show("コメントを入力してください...", style: JFMinimalNotificationStytle.StyleWarning)
                return
            }
            
            let completion = {(isError: Bool) -> Void in
                if isError {
                    Toast.show("コメントできませんでした...", style: JFMinimalNotificationStytle.StyleError)
                    return
                }
                self.fin()
            }
            
            if let comm = self.targetComment {
                qiitaAccount.commentEdit(comm.id, text: self.comment.text, completion: completion)
            } else {
                qiitaAccount.comment(self.displayEntryId, text: self.comment.text, completion: completion)
            }
        }
        
    }
    
    func confirmDeleteComment() {
        
        if self.targetComment == nil {
            return
        }
        
        let params = [
            QCKeys.AlertView.Title.rawValue  : "確認",
            QCKeys.AlertView.Message.rawValue: "コメントを削除してもよいですか？",
            QCKeys.AlertView.NoTitle.rawValue: "Cancel",
            QCKeys.AlertView.YesAction.rawValue: AlertViewSender(action: { () -> Void in
                self.deleteComent()
            }, title: "OK")
        ]
        
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.ShowAlertYesNo.rawValue, object: nil, userInfo: params)
    }
    
    func deleteComent() {
        
        if let qiitaAccount = self.account as? QiitaAccount {
            if let comm = self.targetComment {
                qiitaAccount.deleteComment(comm.id, completion: { (isError) -> Void in
                    if isError {
                        Toast.show("削除できませんでした...", style: JFMinimalNotificationStytle.StyleError)
                        return
                    }
                    
                    self.fin()
                })
                
            }
        }
        
    }
    
    func fin() {
        self.targetComment = nil
        self.refresh()
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableView.items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: CommentTableViewCell = tableView.dequeueReusableCellWithIdentifier("CELL") as! CommentTableViewCell
        cell.account = self.account
        cell.tag = indexPath.row
        
        let entity: CommentEntity = self.tableView.items[indexPath.row] as! CommentEntity
        cell.action = {(c: CommentTableViewCell) -> Void in
            self.tapThumb(c)
            return
        }
        cell.editCommentAction = {(c: CommentTableViewCell) -> Void in
            self.tapCommentEdit(c)
        }
        cell.showComment(entity)
        return cell
    }
   
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if self.tableView.page != NSNotFound && indexPath.row + 1 == self.tableView.items.count {
            self.load()
        }
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: 30.0))
        headerView.backgroundColor = UIColor.backgroundSub(0.8)
        
        let headerTitle: UILabel = UILabel(frame: CGRect(x: 8, y: 8, width: self.tableView.bounds.size.width - 16, height: 14.0))
        headerTitle.lineBreakMode = NSLineBreakMode.ByTruncatingMiddle
        headerTitle.textColor = UIColor.textBase()
        headerTitle.font = UIFont.systemFontOfSize(12.0)
        headerTitle.text = self.displayEntryTitle + "のコメント一覧"
        
        headerView.addSubview(headerTitle)
        headerTitle.addConstraintFromLeft(8.0, toRight: 8.0)
        headerTitle.addConstraintFromTop(8.0, toBottom: 8.0)
        return headerView
    }
    
    // MARK: NSNotification
    func receiveKeyboardShowNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboard = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                let keyBoardRect: CGRect = keyboard.CGRectValue()
                self.openCommentField(keyBoardRect.size.height)
            }
        }
    }
    func receiveKeyboardDidShowNotification(notification: NSNotification) {
        self.setupNavigationBar()
    }
    func receiveKeyboardHideNotification(notification: NSNotification) {
        
        if self.inputStatus != .Confirm {
            return
        }
        self.fullscreenComment()
        
    }
    func receiveKeyboardDidHideNotification(notification: NSNotification) {
        
        if self.inputStatus != .Confirm {
            return
        }
        
        let args = [
            QCKeys.AlertController.Style.rawValue      : UIAlertControllerStyle.Alert.rawValue,
            QCKeys.AlertController.Title.rawValue      : "確認",
            QCKeys.AlertController.Description.rawValue: "この内容でコメントしてもよいですか？",
            QCKeys.AlertController.Actions.rawValue    : [
                UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive, handler: { (action) -> Void in
                    self.inputStatus = .None
                    self.dismissCommentField()
                    self.postComment()
                }),
                UIAlertAction(title: "やめる", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                    // 編集終了
                    self.inputStatus = .None
                    self.dismissCommentField()
                    return
                }),
                UIAlertAction(title: "再編集", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                    self.inputStatus = .Writing
                    self.comment.becomeFirstResponder()
                    return
                })
            ]
        ]
        
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.ShowAlertController.rawValue, object: self, userInfo: args as [NSObject : AnyObject])
        
    }
}
