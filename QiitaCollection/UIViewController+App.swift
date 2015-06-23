//
//  UIViewController+App.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/06/23.
//  Copyright (c) 2015年 anz. All rights reserved.
//
import UIKit

extension UIViewController {
    
    func setupNavigation() {
        
        if self.navigationController == nil {
            return
        }
        // タイトルタップ検知したいので…
        let titleView: NavigationTitleView = UINib(nibName: "NavigationTitleView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! NavigationTitleView
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapNavigationBarTitle:")
        titleView.addGestureRecognizer(tapGesture)
        titleView.setTitleText(self.title ?? "")
        self.navigationItem.titleView = titleView
    }
    
    func tapNavigationBarTitle(gesture: UILongPressGestureRecognizer) {
        
        if let navVC = self.navigationController {
            if navVC.childViewControllers.count > 1 {
                navVC.setViewControllers([navVC.childViewControllers[0]], animated: true)
            }
        }
    }
}
