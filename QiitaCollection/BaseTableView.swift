//
//  BaseTableView.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/20.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class BaseTableView: UITableView {

    var total: Int = 0
    var items: [EntityProtocol] = [EntityProtocol]()
    var page: Int = 1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let dummy: UIView = UIView(frame: CGRect.zeroRect)
        self.tableFooterView = dummy
    }
    
    func loadedItems<T:EntityProtocol>(total: Int, items: [T], isError: Bool, isAppendable: ((T) -> Bool)?) {
        
        if isError {
            Toast.show("取得に失敗しました...時間をあけて試してみてください", style: JFMinimalNotificationStytle.StyleWarning)
            return
        }
        if total == 0 {
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

}
