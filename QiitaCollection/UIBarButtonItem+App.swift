//
//  UIBarButtonItem+App.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/03/02.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import Foundation

extension UIBarButtonItem {
    func showGuide(guideType: GuideManager.GuideType) {
        let guideManager: GuideManager = GuideManager(type: guideType)
        guideManager.start(self)
    }
}