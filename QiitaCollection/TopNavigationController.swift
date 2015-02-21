//
//  TopNavigationViewController.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/07.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class TopNavigationController: UINavigationController, UINavigationControllerDelegate {
    
    enum AlertViewStatus {
        case Dismiss,
        Show,
        Wait
    }
    
    // MARK: プロパティ
    lazy var notice: JFMinimalNotification = self.makeNotice()
    var alertView: SCLAlertView?
    var alertViewStatus: AlertViewStatus = .Dismiss
    var isDidAppear: Bool = false

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
        center.addObserver(self, selector: "receiveShowLoading", name: QCKeys.Notification.ShowLoading.rawValue, object: nil)
        center.addObserver(self, selector: "receiveHideLoading", name: QCKeys.Notification.HideLoading.rawValue, object: nil)
        center.addObserver(self, selector: "receiveConfirmYesNoAlert:", name: QCKeys.Notification.ShowAlertYesNo.rawValue, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.isDidAppear = true
        if self.alertView != nil && self.alertViewStatus == .Wait {
            self.receiveShowLoading()
        }
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
    
    func preShowAlert() -> Bool {
        if self.alertView != nil && self.alertViewStatus == .Show {
            self.alertView!.hideView()
            self.alertViewStatus = .Dismiss
        }
        
        self.alertView = SCLAlertView()
        self.alertView!.alertIsDismissed({ () -> Void in
            self.alertViewStatus = .Dismiss
        })
        
        
        if !self.isDidAppear {
            // このタイミングで表示しちゃうと変になっちゃうので、待機
            self.alertViewStatus = .Wait
            return false
        }
        
        return true
    }
    
    func hideAlert() {
        if let view = self.alertView {
            if self.alertViewStatus == .Show {
                view.hideView()
                self.alertViewStatus = .Dismiss
            } else if self.alertViewStatus == .Wait {
                self.alertViewStatus = .Dismiss
            }
        }
    }
    
    // MARK: NSNotification 受信処理
    
    func receiveShowActionSheet(notification: NSNotification) {
        let args: [NSObject: AnyObject] = notification.userInfo!

        let title: String = args[QCKeys.ActionSheet.Title.rawValue] as? String ?? ""
        let desc: String = args[QCKeys.ActionSheet.Description.rawValue] as? String ?? ""

        let alertController: UIAlertController = UIAlertController(title: title, message: desc, preferredStyle: .ActionSheet)
        alertController.popoverPresentationController?.sourceView = self.view
        // TODO: 表示位置を受け取れるようにする (あとArrowDirectionも)
        alertController.popoverPresentationController?.sourceRect = CGRect(x: self.view.frame.size.width * 0.5, y: self.view.frame.size.height, width: 0, height: 0 )
        alertController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue:0)
        
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
    
    
    func receiveShowLoading() {
        
        if !self.preShowAlert() {
            return
        }
        
        self.alertView!.showWaiting(self, title: "Loading...", subTitle: "少々お待ちください...m(_ _)m", closeButtonTitle: nil, duration: 0.0);
        self.alertViewStatus = .Show
    }
    func receiveHideLoading() {
        self.hideAlert()
    }
    
    func receiveConfirmYesNoAlert(notification: NSNotification) {
        
        self.preShowAlert()
        
        let userInfo = notification.userInfo!
        
        let title: String = userInfo[QCKeys.AlertView.Title.rawValue] as? String ?? "注意"
        let message: String = userInfo[QCKeys.AlertView.Message.rawValue]! as String    // 必須なんで想定外だったら落とす
        let noTiltle: String = userInfo[QCKeys.AlertView.NoTitle.rawValue] as? String ?? "いいえ"
        
        // yesアクションは必須
        let yesAction = userInfo[QCKeys.AlertView.YesAction.rawValue]! as AlertViewSender
        self.alertView!.addButton(yesAction.title.isEmpty ? "はい" : yesAction.title, actionBlock: yesAction.action)
        
        self.alertView!.showWarning(self, title: title, subTitle: message, closeButtonTitle: noTiltle, duration: 0.0);
        self.alertViewStatus = .Show
        
    }

    // MARK: UINavigationControllerDelegate
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        let backButton: UIBarButtonItem = UIBarButtonItem()
        backButton.title = ""
        viewController.navigationItem.backBarButtonItem = backButton;
    }
    
}


// NSObjectのサブクラスじゃないと NSNotification に乗っけられない
class AlertViewSender: NSObject {
    let action: SCLActionBlock?
    let title: String
    
    init (action: SCLActionBlock?, title: String) {
        self.action = action
        self.title = title
    }
}


