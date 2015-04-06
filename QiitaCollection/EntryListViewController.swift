//
//  EntryListViewController.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/15.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class EntryListViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    enum ListType : String {
        case
        UserEntries = "投稿したもの",
        AuthedEntries = "フィード",
        UserStocks = "ストックしたもの",
        History = "閲覧履歴"
    }
    typealias DisplayItem = (type: ListType, userId:String?)

    // MARK: UI
    @IBOutlet weak var tableView: BaseTableView!
    
    // MARK: プロパティ
    var otherAccount: OtherAccount? = nil
    var displayItem: DisplayItem? = nil {
        didSet {
            self.title = self.displayItem?.type.rawValue
            if let qiitaId = self.displayItem?.userId {
                self.otherAccount = OtherAccount(qiitaId: qiitaId)
            } else {
                self.otherAccount = nil
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: メソッド
    func refresh() {
        
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.ShowLoading.rawValue, object: nil);
        
        self.tableView.page = 1
        self.loadData()
        
    }
    func loadData() {
        
        let callback = {(total: Int, items: [EntryEntity]) -> Void in
            self.tableView.loadedItems(total, items: items, isAppendable: { (item: EntryEntity) -> Bool in
                return !self.account.existsMuteUser(item.postUser.id)
            })
            NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.HideLoading.rawValue, object: nil)
        }
        
        // リストタイプによってクエリ作成
        var query: String = ""
        switch self.displayItem!.type {
        case .UserEntries:
            if let other = self.otherAccount {
                query = "user:" + self.displayItem!.userId!
                other.searchEntries(self.tableView.page, query: query, completion: callback)
            }
        case .AuthedEntries:
            if let qiitaAccount = self.account as? QiitaAccount {
                qiitaAccount.entries(self.tableView.page, completion: callback)
            }
        case .UserStocks:
            if let other = self.otherAccount {
                other.stockEntries(self.tableView.page, entryId: self.displayItem!.userId!, completion: callback)
            }
        case .History:
            self.account.histories(self.tableView.page, completion: { (items) -> Void in
                self.tableView.loadedItems(items)
                NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.HideLoading.rawValue, object: nil)
            })
        }
        
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableView.items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: EntryTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("CELL") as EntryTableViewCell
        
        if let history = self.tableView.items[indexPath.row] as? HistoryEntity {
            cell.showHistory(history)
        } else {
            cell.showEntry(self.tableView.items[indexPath.row] as EntryEntity)
        }
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if self.tableView.page != NSNotFound && indexPath.row + 1 == self.tableView.items.count {
            self.loadData()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc: EntryDetailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("EntryDetailVC") as EntryDetailViewController
        
        if let history = self.tableView.items[indexPath.row] as? HistoryEntity {
            vc.displayEntryId = history.entryId
        } else {
            vc.displayEntry = self.tableView.items[indexPath.row] as? EntryEntity
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PushViewController.rawValue, object: vc)
    }

}
