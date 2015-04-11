//
//  UserListViewController.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/03/01.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class UserListViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    enum UserListType {
        case
        Stockers,
        Unknown
    }

    // MARK: UI
    @IBOutlet weak var tableView: BaseTableView!
    
    // MARK: プロパティ
    var listType: UserListType = .Unknown {
        didSet {
            switch self.listType {
            case .Stockers:
                self.title = "ストックしてるユーザーリスト"
            case .Unknown:
                self.title = ""
            }
        }
    }
    var entry: Entry? = nil
    var targetEntryId: String? = nil {
        didSet {
            if let entryId = self.targetEntryId {
                entry = Entry(entryId: entryId)
            }
        }
    }
    
    // MARK: ライフサイクル
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        self.refresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARL: メソッド
    func refresh() {
        self.tableView.page = 1
        self.loadUseList()
    }
    
    func loadUseList() {
        let completion = {(total: Int, items: [UserEntity]) -> Void in
            self.tableView.loadedItems(total, items: items, isAppendable: nil)
        }
        
        switch self.listType {
        case .Stockers:
            self.entry?.stockers(self.tableView.page, completion: completion)
        case .Unknown:
            fatalError("unknown list type....")
        }
    }
    
    // MARK: UITableViewDatasource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableView.items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UserListTableViewCell = tableView.dequeueReusableCellWithIdentifier("CELL") as! UserListTableViewCell
        let user: UserEntity = self.tableView.items[indexPath.row] as! UserEntity
        cell.showUser(user)
        return cell
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let user: UserEntity = self.tableView.items[indexPath.row] as! UserEntity
        let vc: UserDetailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("UserDetailVC") as! UserDetailViewController
        vc.displayUserId = user.id
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PushViewController.rawValue, object: vc)
    }
}
