//
//  EntryCollectionViewController.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/07.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class EntryCollectionViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // MARK: UI
    @IBOutlet weak var collectionView: BaseCollectionView!
    
    // MARK: プロパティ
    var query: String = ""
    
    // MARK: ライフサイクル
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longPressGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "longPress:")
        self.collectionView.addGestureRecognizer(longPressGesture)
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.setupRefreshControl { () -> Void in
            self.refresh()
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // クエリが指定されていたら、保存用のボタンを表示
        if !self.query.isEmpty {
            self.displaySaveSearchCondition()
        }
        
        if self.afterDidLoad {
            refresh()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: メソッド
    func displaySaveSearchCondition() {
        let save: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "bar_item_lock"), style: UIBarButtonItemStyle.Plain, target: self, action: "confirmSaveSearchCondition")
        self.navigationItem.rightBarButtonItem = save
        save.showGuide(GuideManager.GuideType.SearchConditionSaveIcon)
    }
    
    func refresh() {
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.ShowLoading.rawValue, object: nil)
        if !self.isViewLoaded() {return}
        self.collectionView.page = 1
        self.load()
    }
    func load() {
        
        let fin = { (total:Int, items:[EntryEntity]) -> Void in
            self.collectionView.loadedItems(total, items: items, isError: false, isAppendable: { (item: EntryEntity) -> Bool in
                return !self.account.existsMuteUser(item.postUser.id)
            })
            NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.HideLoading.rawValue, object: nil)
        }
        if self.query.isEmpty {
            // 新着
            self.account.newEntries(self.collectionView.page, completion: fin)
        } else {
            // 検索
            self.account.searchEntries(self.collectionView.page, query: self.query, completion: fin)
        }
        
    }
    
    func longPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state != UIGestureRecognizerState.Began {
            return
        }
        let tapPoint: CGPoint = gesture.locationInView(self.collectionView)
        let tapIndexPath: NSIndexPath? = self.collectionView.indexPathForItemAtPoint(tapPoint)
        if tapIndexPath == nil {
            // collection view 領域外をタップしたってこと
            return
        }
        let tapEntry: EntryEntity = self.collectionView.items[tapIndexPath!.row] as! EntryEntity
        
        let actions: [UIAlertAction] = [
            UIAlertAction(title: "投稿詳細", style: .Default, handler: { (UIAlertAction) -> Void in
                self.moveEntryDetail(tapEntry)
            }),
            UIAlertAction(title: "コメント", style: .Default, handler: { (UIAlertAction) -> Void in
                self.moveEntryComment(tapEntry)
            }),
            UIAlertAction(title: "ストックユーザー", style: .Default, handler: { (uialertAction) -> Void in
                self.moveStockers(tapEntry)
            }),
            UIAlertAction(title: "タグ", style: UIAlertActionStyle.Default, handler: { (alertAction) -> Void in
                self.openTagList(tapEntry)
            }),
            UIAlertAction(title: tapEntry.postUser.displayName, style: .Default, handler: { (UIAlertAction) -> Void in
                self.moveUserDetail(tapEntry.postUser.id)
            }),
            UIAlertAction(title: "キャンセル", style: .Cancel, handler: { (UIAlertAction) -> Void in
                
            })
        ]
        
        // TODO: そのほかメニュー表示 (記事をストックしているユーザーリスト)
        NSNotificationCenter.defaultCenter()
            .postNotificationName(QCKeys.Notification.ShowAlertController.rawValue,
                object: self,
                userInfo: [
                    QCKeys.AlertController.Title.rawValue: tapEntry.title + " " + tapEntry.postUser.displayName,
                    QCKeys.AlertController.Description.rawValue: tapEntry.beginning,
                    QCKeys.AlertController.Actions.rawValue: actions
                ])
    }
    
    func moveEntryDetail(entry: EntryEntity) {
        let vc: EntryDetailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("EntryDetailVC") as! EntryDetailViewController
        vc.displayEntry = entry
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PushViewController.rawValue, object: vc)
    }
    
    func moveEntryComment(entry: EntryEntity) {
        let vc: CommentListViewController = self.storyboard?.instantiateViewControllerWithIdentifier("CommentsVC") as! CommentListViewController
        vc.displayEntryId = entry.id
        vc.displayEntryTitle = entry.title
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PushViewController.rawValue, object: vc)
    }
    
    func moveStockers(entry: EntryEntity) {
        let vc: UserListViewController = self.storyboard?.instantiateViewControllerWithIdentifier("UserListVC") as! UserListViewController
        vc.listType = .Stockers
        vc.targetEntryId = entry.id
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PushViewController.rawValue, object: vc)
    }
    
    func moveUserDetail(userId: String) {
        let vc: UserDetailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("UserDetailVC") as! UserDetailViewController
        vc.displayUserId = userId
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PushViewController.rawValue, object: vc)
    }
    
    func confirmSaveSearchCondition() {

        let doAciton: AlertViewSender.AlertActionWithText = {(sender: UITextField) -> Void in
            self.account.saveQuery(self.query, title: sender.text)
            Toast.show("検索条件を保存しました", style: JFMinimalNotificationStytle.StyleSuccess)
            NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.ReloadViewPager.rawValue, object: nil)
        }
        let validation: AlertViewSender.AlertValidation = {(sender: UITextField) -> Bool in
            return !sender.text.isEmpty
        }
        let action: AlertViewSender = AlertViewSender(validation: validation, action: doAciton, title: "OK")
        
        let args: [NSString: AnyObject] = [
            QCKeys.AlertView.Title.rawValue: "入力",
            QCKeys.AlertView.Message.rawValue: "保存名を入力してください。以降、この名前で表示されるようになります",
            QCKeys.AlertView.YesAction.rawValue: action,
            QCKeys.AlertView.NoTitle.rawValue: "Cancel",
            QCKeys.AlertView.PlaceHolder.rawValue: "保存名入力"
        ]
        
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.ShowAlertInputText.rawValue, object: nil, userInfo: args)
    }
    
    func openTagList(entity: EntryEntity) {
        
        let vc: SimpleListViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SimpleListVC") as! SimpleListViewController
        vc.items = entity.toTagList()
        vc.title = "タグリスト"
        vc.swipableCell = false
        vc.tapCallback = {(vc: SimpleListViewController, index: Int) -> Void in
            // タグで検索
            let selectedTag: String = vc.items[index]
            vc.dismissGridMenuAnimated(true, completion: { () -> Void in
                let searchVC: EntryCollectionViewController = self.storyboard?.instantiateViewControllerWithIdentifier("EntryCollectionVC") as! EntryCollectionViewController
                searchVC.title = "タグ：" + selectedTag
                searchVC.query = "tag:" + selectedTag
                NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PushViewController.rawValue, object: searchVC)
            })
        }
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PresentedViewController.rawValue, object: vc)
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.collectionView.items.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: EntryCollectionViewCell = self.collectionView.dequeueReusableCellWithReuseIdentifier("CELL", forIndexPath: indexPath) as! EntryCollectionViewCell
        
        let entry: EntryEntity = self.collectionView.items[indexPath.row] as! EntryEntity
        cell.display(entry)
        return cell
        
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if self.collectionView.page != NSNotFound && (indexPath.row + 1) >= self.collectionView.items.count {
            self.load()
        }
        
        if indexPath.row == 0 {
            cell.showGuide(GuideManager.GuideType.EntryCollectionCell, inView: self.view)
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let tapEntry: EntryEntity = self.collectionView.items[indexPath.row] as! EntryEntity
        self.moveEntryDetail(tapEntry)
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let colNum: CGFloat = self.view.frame.size.width >= 700 ? 3.0 : 2.0
        
        let width: CGFloat = (self.view.frame.size.width - (1.0 + colNum)) / colNum
        return CGSize(width: width, height: width)
    }

}
