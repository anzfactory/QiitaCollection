//
//  BaseCollectionView.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/20.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class BaseCollectionView: UICollectionView {

    typealias RefreshAction = () -> Void
    
    var total: Int = 0
    var items: [EntityProtocol] = [EntityProtocol]()
    var page: Int = 1
    
    var refreshControl: UIRefreshControl? = nil
    var refreshAction: RefreshAction? = nil

    func setupRefreshControl(action: RefreshAction) {
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.attributedTitle = NSAttributedString(string: "引っ張って更新")
        self.refreshControl!.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.addSubview(self.refreshControl!)
        self.refreshAction = action
    }
    
    func refresh() {
        
        if let refresh = self.refreshControl {
            refresh.endRefreshing()
        }
        
        if let action = self.refreshAction {
            action()
        }
    }
    
    func loadedItems<T:EntityProtocol>(total:Int, items: [T], isError: Bool, isAppendable: ((T) -> Bool)?) {
        
        if isError {
            Toast.show("取得に失敗しました...時間をあけて試してみてください", style: JFMinimalNotificationStytle.StyleWarning)
            return
        }
        if total == 0 {
            Toast.show("結果0件でした...", style: JFMinimalNotificationStytle.StyleInfo)
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
    
    func loadedItems<T:EntityProtocol>(items: [T], isError: Bool) {
        
        if isError {
            Toast.show("取得に失敗しました...時間をあけて試してみてください", style: JFMinimalNotificationStytle.StyleWarning)
            return
        }
        self.total = items.count
        self.page = NSNotFound      // オートページング止めるために
        
        // リフレッシュ対象なのでリストクリア
        self.items.removeAll(keepCapacity: false)
        
        
        for item: T in items {
            self.items.append(item)
        }
        
//        self.page++
        self.reloadData()
    }

}
