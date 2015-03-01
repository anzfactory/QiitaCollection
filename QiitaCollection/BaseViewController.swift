//
//  BaseViewController.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/12.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    func publicMenuItems() -> [PathMenuItem] {
        return[]
    }

}
