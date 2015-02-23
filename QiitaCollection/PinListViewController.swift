//
//  PinListViewController.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/24.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class PinListViewController: SimpleListViewController {

    override func tapSwipeableCellRight(cell: SWTableViewCell, didTriggerRightUtilityButtonWithIndex index: Int) {
        UserDataManager.sharedInstance.clearPinEntry(cell.tag)
        // 再作成
        self.items.removeAtIndex(cell.tag)
        self.tableView.reloadData()
        Toast.show("pinした投稿を解除しました", style: JFMinimalNotificationStytle.StyleSuccess, title: "", targetView: self.view)
    }
}
