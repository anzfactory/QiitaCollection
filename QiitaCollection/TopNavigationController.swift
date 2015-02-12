//
//  TopNavigationViewController.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/07.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class TopNavigationController: UINavigationController, UINavigationControllerDelegate {

    // MARK: ライフサイクル
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self;
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.textNavigationBar()]
        self.navigationBar.barTintColor = UIColor.backgroundNavigationBar()
        self.navigationBar.tintColor = UIColor.textNavigationBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receiveShowActionSheet:", name: QCKeys.Notification.ShowActionSheet.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivePushViewController:", name: QCKeys.Notification.PushViewController.rawValue, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        super.viewWillDisappear(animated)
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
    func receiveShowActionSheet(notification: NSNotification) {
        let args: [NSObject: AnyObject] = notification.userInfo!

        let title: String = args[QCKeys.ActionSheet.Title.rawValue] as? String ?? ""
        let desc: String = args[QCKeys.ActionSheet.Description.rawValue] as? String ?? ""

        let alertController: UIAlertController = UIAlertController(title: title, message: desc, preferredStyle: .ActionSheet)
        
        if let actions: [UIAlertAction] = args[QCKeys.ActionSheet.Actions.rawValue] as? [UIAlertAction] {
            for action: UIAlertAction in actions {
                alertController.addAction(action)
            }
            
        }
        
        self.presentViewController(alertController, animated: true) { () -> Void in
            
        }
        
    }
    
    func receivePushViewController(notification: NSNotification) {
        let vc: UIViewController = notification.object! as UIViewController
        self.pushViewController(vc, animated: true)
    }

    // MARK: UINavigationControllerDelegate
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        let backButton: UIBarButtonItem = UIBarButtonItem()
        backButton.title = ""
        viewController.navigationItem.backBarButtonItem = backButton;
    }
}
