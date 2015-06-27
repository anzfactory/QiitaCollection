//
//  BaseViewController.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/12.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    private(set) var afterDidLoad: Bool = false
    lazy var account: AnonymousAccount = self.setupAccount();
    var transitionSenderPoint: CGPoint? = nil
    
    private var navBar: UINavigationBar? = nil
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.transitioningDelegate = self
    }
    
    override var title: String? {
        didSet {
            // NavigatonBarのタイトルにカスタムタイトル(UILabek)をつかってるんで
            // VCの方で遅延的にタイトルを設定した場合、反映されないので…
            // 監視して、カスタムの方へ投げてる
            if let navigationTitleView = self.navigationItem.titleView as? NavigationTitleView {
                navigationTitleView.setTitleText(self.title!)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigation()
        self.afterDidLoad = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.afterDidLoad = false
        
        if let item = navBar?.topItem {
            if let view = item.leftBarButtonItem?.valueForKey("view") as? UIView {
                self.transitionSenderPoint = navBar!.convertPoint(view.center, toView: self.view)
            } else {
                println("can not find view")
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // guideが表示されてるかもなのでクリア
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.ClearGuide.rawValue, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    func publicMenuItems() -> [PathMenuItem] {
        return[]
    }
    
    func setupForPresentedVC(navigationbar: UINavigationBar) {
        self.view.backgroundColor = UIColor.backgroundBase()
        navigationbar.translucent = false
        navigationbar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.textNavigationBar()]
        navigationbar.barTintColor = UIColor.backgroundNavigationBar()
        navigationbar.tintColor = UIColor.textNavigationBar()
        
        navBar = navigationbar
    }
    
    
    func setupAccount() -> AnonymousAccount {
        return AccountManager.account()
    }
    
    // MARK: UIViewControllerTransitioningDelegate
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        var point: CGPoint = CGPointZero
        if let p = self.transitionSenderPoint {
            point = p
        } else {
            point = self.view.center
        }
        self.transitionSenderPoint = nil
        return CircularRevealAnimator(center: point, duration: 0.3, spreading: true)
        
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        var point: CGPoint = CGPointZero
        if let p = self.transitionSenderPoint {
            point = p
        } else {
            point = self.view.center
        }
        self.transitionSenderPoint = nil
        return CircularRevealAnimator(center: point, duration: 0.3, spreading: false)
    }

}
