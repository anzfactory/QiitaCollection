//
//  BaseViewController.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/12.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

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
