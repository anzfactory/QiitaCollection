//
//  TopNavigationViewController.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/07.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class TopNavigationController: UINavigationController, UINavigationControllerDelegate {
    
    // MARK: プロパティ
    lazy var notice: JFMinimalNotification = self.makeNotice()

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
        
        let center: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: "receiveShowActionSheet:", name: QCKeys.Notification.ShowActionSheet.rawValue, object: nil)
        center.addObserver(self, selector: "receivePushViewController:", name: QCKeys.Notification.PushViewController.rawValue, object: nil)
        center.addObserver(self, selector: "receiveShowMinimumNotification:", name: QCKeys.Notification.ShowMinimumNotification.rawValue, object: nil)
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
    
    func makeNotice() -> JFMinimalNotification {
        let notice: JFMinimalNotification = JFMinimalNotification(style: JFMinimalNotificationStytle.StyleDefault, title: " ", subTitle: " ", dismissalDelay: 3.0) { () -> Void in
            self.notice.dismiss()
        }
        notice.setTitleFont(UIFont(name: "HiraKakuProN-W6", size: 14.0))
        notice.setSubTitleFont(UIFont(name: "Hiragino Kaku Gothic ProN", size: 12.0))
        self.view.addSubview(notice)
        notice.layoutIfNeeded()
        notice.presentFromTop = false
        return notice
    }
    
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
    
    func receiveShowMinimumNotification(notification: NSNotification) {
        
        let userInfo = notification.userInfo!
        var title: String = userInfo[QCKeys.MinimumNotification.Title.rawValue] as? String ?? ""
        let subTitle: String = userInfo[QCKeys.MinimumNotification.SubTitle.rawValue] as? String ?? ""
        let styleNumber: NSNumber = userInfo[QCKeys.MinimumNotification.Style.rawValue] as NSNumber
        let style: JFMinimalNotificationStytle = JFMinimalNotificationStytle(rawValue: styleNumber.integerValue) ?? JFMinimalNotificationStytle.StyleDefault
        
        if (title.isEmpty) {
            switch style {
            case .StyleDefault:
                title = "(´・ω・`)"
            case .StyleInfo:
                title = "(｡･ω･｡)"
            case .StyleSuccess:
                title = "٩( 'ω' )و"
            case .StyleWarning:
                title = "ヾ(･ω･´;)ﾉ"
            case .StyleError:
                title = "Σ(°Д°；≡；°д°)"
            }
        }
        
        self.notice.titleLabel.text = title;
        self.notice.subTitleLabel.text = subTitle
        self.notice.setStyle(style, animated: false)
        
        self.notice.show()
    }

    // MARK: UINavigationControllerDelegate
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        let backButton: UIBarButtonItem = UIBarButtonItem()
        backButton.title = ""
        viewController.navigationItem.backBarButtonItem = backButton;
    }
    
}
