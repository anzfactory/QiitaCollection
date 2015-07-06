//
//  AdventListViewController.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/07/06.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class AdventListViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: UI
    @IBOutlet weak var tableView: BaseTableView!
    
    // MARK: プロパティ
    var displayYear: Int = 2014
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Advent"
        
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.separatorColor = UIColor.borderNavigationMenuSeparator()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.setupRefreshControl { () -> Void in
            self.refresh()
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.afterDidLoad {
            self.refresh()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: メソッド
    func refresh() {
        self.tableView.page = 1
        self.loadData()
    }
    
    func loadData() {
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.ShowLoadingWave.rawValue, object: nil);
        self.account.adventList(self.displayYear, page: self.tableView.page) { (items) -> Void in
            self.tableView.loadedItems(items)
            NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.HideLoadingWave.rawValue, object: nil)
        }
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableView.items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: AdventListTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("CELL") as! AdventListTableViewCell
        let item: KimonoEntity = self.tableView.items[indexPath.row] as! KimonoEntity
        
        cell.show(item)
        return cell
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if self.tableView.page != NSNotFound && indexPath.row + 1 == self.tableView.items.count {
            self.loadData()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc: AdventCalendarViewController = self.storyboard?.instantiateViewControllerWithIdentifier("AdventCalendarVC") as! AdventCalendarViewController
        
        let item: KimonoEntity = self.tableView.items[indexPath.row] as! KimonoEntity
        vc.kimono = item
        
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PushViewController.rawValue, object: vc)
    }
}
