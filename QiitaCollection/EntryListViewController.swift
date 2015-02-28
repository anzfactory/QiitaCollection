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
        UserStocks = "ストックしたもの"
    }
    typealias DisplayItem = (type: ListType, query: String)

    // MARK: UI
    @IBOutlet weak var tableView: BaseTableView!
    
    // MARK: プロパティ
    var displayItem: DisplayItem? = nil {
        didSet {
            self.title = self.displayItem!.type.rawValue
        }
    }
    let qiitaManager: QiitaApiManager = QiitaApiManager()
    
    // MARK: ライフサイクル
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
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
        
        let callback = {(total: Int, items: [EntryEntity], isError: Bool) -> Void in
            self.tableView.loadedItems(total, items: items, isError: isError, isAppendable: { (item: EntryEntity) -> Bool in
                return !contains(UserDataManager.sharedInstance.muteUsers, item.postUser.id)
            })
            NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.HideLoading.rawValue, object: nil)
        }
        
        // リストタイプによってクエリ作成
        var query: String = ""
        switch self.displayItem!.type {
        case .UserEntries:
            query = "user:" + self.displayItem!.query
            self.qiitaManager.getEntriesSearch(query, page: self.tableView.page, completion: callback)
        case .UserStocks:
            self.qiitaManager.getEntriesUserStocks(self.displayItem!.query, page: self.tableView.page, completion: callback)
        }
        
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableView.items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: EntryTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("CELL") as EntryTableViewCell
        cell.showEntry(self.tableView.items[indexPath.row] as EntryEntity)
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
        vc.displayEntry = self.tableView.items[indexPath.row] as? EntryEntity
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PushViewController.rawValue, object: vc)
    }

}
