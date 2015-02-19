//
//  QCKeys.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/11.
//  Copyright (c) 2015年 anz. All rights reserved.
//

struct QCKeys {
    
    enum Notification: String {
        case ShowActionSheet = "QC_NotificationKey_ShowActionSheet"
        case PushViewController = "QC_NotificationKey_PushViewController"
        case ShowMinimumNotification = "QC_NotificationKey_MinimumNtofice"
        case ShowLoading = "QC_NotificationKey_ShowLoading"
        case HideLoading = "QC_NotificationKey_HideLoading"
    }
    
    enum ActionSheet: String {
        case
        Title = "Title",
        Description = "Description",
        Actions = "Actions"
    }
    
    enum MinimumNotification: String {
        case
        Title = "Title",
        SubTitle = "SubTitle",
        Style = "Style"
    }
}
