//
//  AdventCalendarViewController.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/07/06.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class AdventCalendarViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: BaseTableView!
    
    // MARK: プロパティ
    var kimono: KimonoEntity? = nil
    
    // MARK: ライフサイクル
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longPressGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "longPress:")
        self.tableView.addGestureRecognizer(longPressGesture)

        
        self.tableView.estimatedRowHeight = 66
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
        
        if let entity = self.kimono {
            self.title = entity.title
        }
        
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
        if let entity = self.kimono {
            NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.ShowLoadingWave.rawValue, object: nil);
            self.account.adventEntires(entity.objectId, completion: { (items) -> Void in
                self.tableView.loadedItems(items)
                NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.HideLoadingWave.rawValue, object: nil)
            })
        }
    }
    
    func longPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state != UIGestureRecognizerState.Began {
            return
        }
        let tapPoint: CGPoint = gesture.locationInView(self.tableView)
        let tapIndexPath: NSIndexPath? = self.tableView.indexPathForRowAtPoint(tapPoint)
        if tapIndexPath == nil {
            // collection view 領域外をタップしたってこと
            return
        }
        let tapEntity: AdventEntity = self.tableView.items[tapIndexPath!.row] as! AdventEntity
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("UserDetailVC") as! UserDetailViewController
        vc.displayUserId = tapEntity.author
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PushViewController.rawValue, object: vc)
    }

    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableView.items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: AdventCalendarTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("CELL") as! AdventCalendarTableViewCell
        let item: AdventEntity = self.tableView.items[indexPath.row] as! AdventEntity
        
        cell.show(item)
        return cell
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            GuideManager.sharedInstance.start(GuideManager.GuideType.AdventCalendarCell, target: cell, inView: self.tableView)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let item: AdventEntity = self.tableView.items[indexPath.row] as! AdventEntity
        if item.url.isEmpty {
            Toast.show("記事が掲載されていません", style: JFMinimalNotificationStytle.StyleWarning)
            return;
        }
        
        let url = NSURL(string: item.url)!
        let urlParse = url.parse()
        let vc: UIViewController
        var notificationKey = QCKeys.Notification.PushViewController.rawValue
        if let entryId = urlParse.entryId {
            let entryVc = self.storyboard?.instantiateViewControllerWithIdentifier("EntryDetailVC") as! EntryDetailViewController
            entryVc.displayEntryId = entryId
            vc = entryVc
        } else {
            let browserVc = self.storyboard?.instantiateViewControllerWithIdentifier("SimpleBrowserVC") as! SimpleBrowserViewController
            browserVc.displayAdvent = item
            vc = browserVc
            notificationKey = QCKeys.Notification.PresentedViewController.rawValue
        }
        NSNotificationCenter.defaultCenter().postNotificationName(notificationKey, object: vc)
    }
    

}
