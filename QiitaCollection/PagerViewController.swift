//
//  PagerViewController.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/09.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class PagerViewController: BaseViewController {

    // MARK: プロパティ
    var leftBarItem: UIBarButtonItem?
    var pageMenu : CAPSPageMenu!
    var controllerArray : [UIViewController] = []
    
    // MARK: ライフサイクル
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "(ﾟ∀ﾟ)ｷﾀｺﾚ!!"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_setting"), style: UIBarButtonItemStyle.Plain, target: self, action: "tapSetting")
        
        let vc : UIViewController = self.storyboard?.instantiateViewControllerWithIdentifier("EntryCollectionVC") as UIViewController
        vc.title = "新着"
        controllerArray.append(vc)
        
        var parameters: [String: AnyObject] = ["menuItemSeparatorWidth": 4.3,
            "useMenuLikeSegmentedControl": true,
            "menuItemSeparatorPercentageHeight": 0.1,
            "bottomMenuHairlineColor" : UIColor.borderPageMenuIndicator(),
            "selectionIndicatorColor" : UIColor.borderPageMenuIndicator(),
            "selectedMenuItemLabelColor" : UIColor.textPageMenuLabel(),
            "unselectedMenuItemLabelColor" : UIColor.textPageMenuLabel(),
            "menuItemFont" : UIFont.boldSystemFontOfSize(14.0)]
        
        self.pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRectMake(0.0, 0.0, self.view.frame.width, self.view.frame.height), options: parameters)
        self.view.addSubview(self.pageMenu!.view)

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.pageMenu.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.pageMenu.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: メソッド
    func tapSetting() {
    }

}
