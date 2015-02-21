//
//  Toast.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/21.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class Toast: NSObject {
   
    class func show(message: String, style: JFMinimalNotificationStytle, title: String = "", targetView: UIView? = nil) {
        NSNotificationCenter.defaultCenter()
            .postNotificationName(QCKeys.Notification.ShowMinimumNotification.rawValue,
                object: targetView,
                userInfo: [
                    QCKeys.MinimumNotification.Title.rawValue: title,
                    QCKeys.MinimumNotification.SubTitle.rawValue: message,
                    QCKeys.MinimumNotification.Style.rawValue: NSNumber(integer: style.rawValue)
                ])
    }
    
}
