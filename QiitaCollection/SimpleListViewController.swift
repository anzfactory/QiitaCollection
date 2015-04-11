//
//  SimpleListViewController.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/21.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class SimpleListViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, SWTableViewCellDelegate {
    
    typealias ItemTapCallback = (SimpleListViewController, Int) -> Void
    typealias SwipeCellCallback = (SimpleListViewController, SlideTableViewCell, Int) -> Void

    // MARK: UI
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationTitleItem: UINavigationItem!
    
    // MARK: プロパティ
    var items: [String] = [String]()
    var swipableCell: Bool = true
    var tapCallback: ItemTapCallback? = nil
    var swipeCellCallback: SwipeCellCallback? = nil
    var removeNavigationBar: Bool = false
    var cellGuide: GuideManager.GuideType = .None
    
    // MARK: ライフサイクル
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupForPresentedVC(self.navigationBar)
        
        let dummy: UIView = UIView(frame: CGRect.zeroRect)
        self.tableView.tableFooterView = dummy
        self.tableView.separatorColor = UIColor.borderTableView()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.removeNavigationBar {
            if let navBar = self.navigationBar {
                navBar.removeFromSuperview()
                self.tableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                self.tableView.addConstraintFromTop(0.0)
            }
        } else {
            self.navigationTitleItem.title = self.title
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Actions
    @IBAction func tapClose(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }
    
    // MARK: メソッド
    func refresh(items: [String]) {
        self.items = items
        self.tableView.reloadData()
    }
    
    func removeItem(index: Int) {
        if index >= self.items.count {
            return;
        }
        self.items.removeAtIndex(index)
        self.tableView.reloadData()
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44.0
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: SlideTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("CELL") as! SlideTableViewCell

        if !cell.isReused {
            cell.delegate = self
        }
        
        cell.textLabel?.text = self.items[indexPath.row]
        cell.tag = indexPath.row
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let callback = self.tapCallback {
            callback(self, indexPath.row)
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 && self.cellGuide != .None {
            cell.showGuide(self.cellGuide, inView: self.view)
        }
    }
    
    // MARK: SWTableViewCellDelegate
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerRightUtilityButtonWithIndex index: Int) {
        self.swipeCellCallback?(self, cell as! SlideTableViewCell, cell.tag)
    }
    
    func swipeableTableViewCell(cell: SWTableViewCell!, canSwipeToState state: SWCellState) -> Bool {
        return self.swipableCell
    }
}
