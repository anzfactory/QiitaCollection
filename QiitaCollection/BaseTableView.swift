//
//  BaseTableView.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/20.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class BaseTableView: UITableView {

    typealias RefreshAction = () -> Void
    
    var total: Int = 0
    var items: [EntityProtocol] = [EntityProtocol]()
    var page: Int = 1
    var refreshControl: UIRefreshControl? = nil
    var refreshAction: RefreshAction? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let dummy: UIView = UIView(frame: CGRect.zeroRect)
        self.tableFooterView = dummy
        
    }
    
    func setupRefreshControl(action: RefreshAction) {
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.attributedTitle = NSAttributedString(string: "引っ張って更新")
        self.refreshControl!.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.addSubview(self.refreshControl!)
    }
    
    func refresh() {
        
        if let refresh = self.refreshControl {
            refresh.endRefreshing()
        }
        
        if let action = self.refreshAction {
            action()
        }
    }
    
    func loadedItems<T:EntityProtocol>(total: Int, items: [T], isAppendable: ((T) -> Bool)?) {
        
        if total == 0 && self.page == 1 {
            Toast.show("結果0件でした...", style: JFMinimalNotificationStytle.StyleWarning)
            return
        }
        self.total = total
        if items.count == 0 {
            self.page = NSNotFound      // オートページング止めるために
            return
        } else if (self.page == 1) {
            // リフレッシュ対象なのでリストクリア
            self.items.removeAll(keepCapacity: false)
        }
        
        for item: T in items {
            if (isAppendable == nil || isAppendable!(item)) {
                self.items.append(item)
            }
        }
        
        self.page++
        self.reloadData()

    }
    
    func loadedItems(items: [HistoryEntity]) {
        
        if items.count == 0 && self.page == 1 {
            Toast.show("結果0件でした...", style: JFMinimalNotificationStytle.StyleWarning)
            return
        }
        self.total = self.items.count + items.count
        if items.count == 0 {
            self.page = NSNotFound      // オートページング止めるために
            return
        } else if (self.page == 1) {
            // リフレッシュ対象なのでリストクリア
            self.items.removeAll(keepCapacity: false)
        }
        
        for item: HistoryEntity in items {

            self.items.append(item)
    
        }
        
        self.page++
        self.reloadData()

    }
    
    func clearItems() {
        if self.items.count == 0 {
            return
        }
        
        self.items.removeAll(keepCapacity: false)
        self.reloadData()
    }

}
