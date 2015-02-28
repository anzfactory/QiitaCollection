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
    let qiitaManager: QiitaApiManager = QiitaApiManager()
    var displayEntryId: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "コメント"
        self.tableView.estimatedRowHeight = 104
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.dataSource = self
        self.tableView.delegate = self
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
   
}
