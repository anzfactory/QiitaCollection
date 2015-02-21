//
//  BaseTableView.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/20.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class BaseTableView: UITableView {

    var items: [EntityProtocol] = [EntityProtocol]()
    var page: Int = 1
    
    override func awakeFromNib() {
        let dummy: UIView = UIView(frame: CGRect.zeroRect)
        self.tableFooterView = dummy
    }
    
    func loadedItems<T:EntityProtocol>(items: [T], isError: Bool, isAppendable: ((T) -> Bool)?) {
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.HideLoading.rawValue, object: nil);
        
        if isError {
            NSNotificationCenter.defaultCenter()
                .postNotificationName(QCKeys.Notification.ShowMinimumNotification.rawValue,
                    object: nil,
                    userInfo: [
                        QCKeys.MinimumNotification.SubTitle.rawValue: "取得に失敗しました...時間をあけて試してみてください",
                        QCKeys.MinimumNotification.Style.rawValue: NSNumber(integer: JFMinimalNotificationStytle.StyleWarning.rawValue)
                    ])
            return
        }
        
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
