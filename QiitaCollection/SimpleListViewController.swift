//
//  SimpleListViewController.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/21.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class SimpleListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    typealias ItemTapCallback = (SimpleListViewController, Int) -> Void

    // MARK: UI
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: プロパティ
    var items: [String] = [String]()
    var tapCallback: ItemTapCallback? = nil
    
    // MARK: ライフサイクル
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let nav = self.navigationController {
            // ナビゲーションコントローラー
            nav.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.textNavigationBar()]
            nav.navigationBar.barTintColor = UIColor.backgroundNavigationBar()
            nav.navigationBar.tintColor = UIColor.textNavigationBar()
            
            let close: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_x"), style: UIBarButtonItemStyle.Plain, target: self, action: "tapClose")
            self.navigationItem.leftBarButtonItem = close
        }
        
        let dummy: UIView = UIView(frame: CGRect.zeroRect)
        self.tableView.tableFooterView = dummy
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: メソッド
    func tapClose() {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }
    
    // MARK: UITableViewDataSource

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("CELL") as UITableViewCell
        
        cell.textLabel?.text = self.items[indexPath.row]
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let callback = self.tapCallback {
            callback(self, indexPath.row)
        }
    }
}
