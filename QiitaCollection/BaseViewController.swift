//
//  BaseViewController.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/12.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    private(set) var afterDidLoad: Bool = false
    
    override var title: String? {
        didSet {
            // NavigatonBarのタイトルにカスタムタイトル(UILabek)をつかってるんで
            // VCの方で遅延的にタイトルを設定した場合、反映されないので…
            // 監視して、カスタムの方へ投げてる
            if let customTitle = self.navigationItem.titleView as? UILabel {
                customTitle.text = self.title
                customTitle.sizeToFit()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.afterDidLoad = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.afterDidLoad = false
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
    }

}
