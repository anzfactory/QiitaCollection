//
//  EntryListViewController.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/15.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class EntryListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    enum ListType : String {
        case UserEntries = "投稿したもの"
    }
    typealias DisplayItem = (type: ListType, query: String)

    // MARK: UI
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: プロパティ
    var entries: [EntryEntity] = [EntryEntity]()
    var displayItem: DisplayItem? = nil {
        didSet {
            self.title = self.displayItem!.type.rawValue
        }
    }
    let qiitaManager: QiitaApiManager = QiitaApiManager()
    var page: Int = 1
    
    // MARK: ライフサイクル
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: メソッド
    func refresh() {
        self.page = 1
        self.loadData()
    }
    func loadData() {
        // リストタイプによってクエリ作成
        var query: String = ""
        switch self.displayItem!.type {
        case .UserEntries:
            query = "user:" + self.displayItem!.query
        }
        self.qiitaManager.getEntriesSearch(query, page: self.page) { (items, isError) -> Void in
            
            if isError {
                println("error")
                // TODO: アラートなりトーストなりでユーザー通知 (リトライとか？)
                return
            }
            
            if items.count == 0 {
                self.page = NSNotFound      // オートページング止めるために
                return
            } else if (self.page == 1) {
                // リフレッシュ対象なのでリストクリア
                self.entries.removeAll(keepCapacity: false)
            }
            
            for item: EntryEntity in items {
                self.entries.append(item)
            }
            
            self.page++
            self.tableView.reloadData()
            
        }
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.entries.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: EntryTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("CELL") as EntryTableViewCell
        cell.showEntry(self.entries[indexPath.row])
        return cell
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if self.page != NSNotFound && indexPath.row + 1 == self.entries.count {
            self.loadData()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc: EntryDetailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("EntryDetailVC") as EntryDetailViewController
        vc.displayEntry = self.entries[indexPath.row]
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PushViewController.rawValue, object: vc)
    }

}
