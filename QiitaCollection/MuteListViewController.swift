//
//  MuteListViewController.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/24.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class MuteListViewController: SimpleListViewController {

    override func tapSwipeableCellRight(cell: SWTableViewCell, didTriggerRightUtilityButtonWithIndex index: Int) {
        self.items = UserDataManager.sharedInstance.clearMutedUser(self.items[cell.tag])
        self.tableView.reloadData()
        Toast.show("ミュートを解除しました", style: JFMinimalNotificationStytle.StyleSuccess, title: "", targetView: self.view)
    }

}
