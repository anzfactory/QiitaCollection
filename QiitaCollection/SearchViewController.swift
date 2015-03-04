//
//  SearchViewController.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/22.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class SearchViewController: BaseViewController, SearchConditionViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, SWTableViewCellDelegate {

    typealias SearchConditionItem = (query:String, isExclude:Bool, type: SearchConditionView.SearchType)
    typealias SearchCallback = (SearchViewController, String) -> Void
    
    // MARK: UI
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var searchConditionView: SearchConditionView!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: 制約
    @IBOutlet weak var constraintHeightSearchCondition: NSLayoutConstraint!
    
    // プロパティ
    var items: [SearchConditionItem] = [SearchConditionItem]()
    var tapGesture: UITapGestureRecognizer!
    var callback: SearchCallback?

    // MARK: ライフサイクル
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupForPresentedVC(self.navigationBar)
        
        self.searchConditionView.delegate = self
        self.searchConditionView.query.delegate = self
        self.searchConditionView.showGuide(GuideManager.GuideType.SearchConditionView, inView: self.view)
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zeroRect)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.tapGesture = UITapGestureRecognizer(target: self, action: "tapView:")
        self.view.addGestureRecognizer(self.tapGesture)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receiveKeyboardShowNotification:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receiveKeyboardHideNotification:", name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Actions
    @IBAction func tapClose(sender: AnyObject) {
        self.dismiss()
    }
    
    // MARK: メソッド
    func tapSearch() {
        
        // もし入力中のものがあればついか
        if !self.searchConditionView.query.text.isEmpty {
            self.addCondition()
        }
        
        if self.items.isEmpty {
            if self.searchConditionView.query.text.isEmpty {
                Toast.show("検索キーワードを入力してください", style: JFMinimalNotificationStytle.StyleWarning, title: "", targetView: self.searchConditionView)
                return
            }
        }
        
        // サーチ
        self.searchConditionView.doSearch.enabled = false
        self.view.endEditing(true)
        
        // 検索クエリを作って渡す
        var q: String = ""
        for item in self.items {
            q += String(format: " %@%@%@", item.isExclude ? "-" : "", item.type.query(), item.query)
        }
        q = q.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        self.callback?(self, q)
    }
    
    func receiveKeyboardShowNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboard = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                let keyBoardRect: CGRect = keyboard.CGRectValue()
                self.constraintHeightSearchCondition.constant = keyBoardRect.size.height
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    func receiveKeyboardHideNotification(notification: NSNotification) {
        self.constraintHeightSearchCondition.constant = 0.0
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    func tapView(gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func dismiss() {
        self.view.endEditing(true)
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }
    
    func addCondition() {
        let item: SearchConditionItem = SearchConditionItem(query: self.searchConditionView.query.text, isExclude: self.searchConditionView.excludeCheck.selected, type: SearchConditionView.SearchType(rawValue: self.searchConditionView.searchType.selectedSegmentIndex)!)
        self.items.append(item)
        
        self.tableView.reloadData()
        
        self.searchConditionView.clear()
    }
    
    func deleteSeachCondition(index: Int) {
        self.items.removeAtIndex(index)
        self.tableView.reloadData()
    }

    // MARK: SearchConditionViewDelegate
    func searchVC(viewController: SearchConditionView, sender: UIButton) {
        
        if sender == viewController.doSearch {
            self.tapSearch()
        }
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 56.0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: SearchTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("CELL") as SearchTableViewCell
        cell.show(self.items[indexPath.row])
        cell.delegate = self
        cell.tag = indexPath.row
        return cell
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            cell.showGuide(.SearchConditionSwaipeCell, inView: self.view)
        }
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.addCondition()
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: SWTableViewCellDelegate
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerRightUtilityButtonWithIndex index: Int) {
        if index == 0 {
            self.deleteSeachCondition(cell.tag)
        }
    }
}
