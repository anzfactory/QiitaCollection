//
//  CommentListViewController.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/28.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class CommentListViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: UI
    @IBOutlet weak var tableView: BaseTableView!
    
    // MARK: プロパティ
    let qiitaManager: QiitaApiManager = QiitaApiManager.sharedInstance
    var displayEntryId: String = ""
    var displayEntryTitle: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "コメント"
        self.tableView.estimatedRowHeight = 104
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.setupRefreshControl { () -> Void in
            self.refresh()
        }
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
    func refresh() {
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.ShowLoading.rawValue, object: nil)
        self.tableView.page = 1
        self.load()
    }
    
    func load() {
        self.qiitaManager.getEntriesComments(self.displayEntryId, page: self.tableView.page) { (total, items, isError) -> Void in
            
            if total == 0 {
                Toast.show("コメントが投稿されていません…", style: JFMinimalNotificationStytle.StyleInfo)
            } else {
                self.tableView.loadedItems(total, items: items, isError: isError, isAppendable: nil)
            }
            NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.HideLoading.rawValue, object: nil)
            return
        }
    }
    
    func tapThumb(cell: CommentTableViewCell) {
        let entity: CommentEntity = self.tableView.items[cell.tag] as CommentEntity
        let vc: UserDetailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("UserDetailVC") as UserDetailViewController
        vc.displayUserId = entity.postUser.id
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PushViewController.rawValue, object: vc)
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableView.items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: CommentTableViewCell = tableView.dequeueReusableCellWithIdentifier("CELL") as CommentTableViewCell
        cell.tag = indexPath.row
        
        let entity: CommentEntity = self.tableView.items[indexPath.row] as CommentEntity
        cell.action = {(c: CommentTableViewCell) -> Void in
            self.tapThumb(c)
            return
        }
        cell.showComment(entity)
        return cell
    }
   
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
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
}
