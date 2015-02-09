//
//  PagerViewController.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/09.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class PagerViewController: UIViewController, UINavigationControllerDelegate {

    // MARK: プロパティ
    var leftBarItem: UIBarButtonItem?
    var pageMenu : CAPSPageMenu!
    var controllerArray : [UIViewController] = []
    
    // MARK: ライフサイクル
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "(ﾟ∀ﾟ)ｷﾀｺﾚ!!"
        
        let vc : UINavigationController = self.storyboard?.instantiateViewControllerWithIdentifier("ContentNavigationController") as UINavigationController
        vc.delegate = self
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: メソッド
    
    func makeLeftBarItem () {
        let barButton: UIButton = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        barButton.frame = CGRectMake(0, 0, 32.0, 32.0)
        barButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        barButton.setImage(UIImage(named: "arrow_left")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        barButton.tintColor = UIColor.textNavigationBar()
        barButton.addTarget(self, action: "tapBack", forControlEvents: UIControlEvents.TouchUpInside)
        self.leftBarItem = UIBarButtonItem(customView: barButton)
        self.navigationItem.leftBarButtonItem = self.leftBarItem
    }
    
    func tapBack() {
        let current: UINavigationController = self.controllerArray[self.pageMenu.currentPageIndex] as UINavigationController
        current.popViewControllerAnimated(true)
    }
    
    // MARK: UINavigationControllerDelegate
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        
        if navigationController.childViewControllers.count > 1 && self.leftBarItem == nil {
            self.makeLeftBarItem()
        } else if navigationController.childViewControllers.count == 1 {
            self.navigationItem.leftBarButtonItem = nil
            self.leftBarItem = nil
        }
        
    }

}
