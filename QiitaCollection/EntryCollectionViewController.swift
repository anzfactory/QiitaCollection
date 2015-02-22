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
    var qiitaManager: QiitaApiManager = QiitaApiManager()
    
    // MARK: ライフサイクル
    override func viewDidLoad() {
        super.viewDidLoad()
        let longPressGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "longPress:")
        self.collectionView.addGestureRecognizer(longPressGesture)
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: メソッド
    func refresh() {
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.ShowLoading.rawValue, object: nil)
        if !self.isViewLoaded() {return}
        self.collectionView.page = 1
        self.load()
    }
    func load() {
        self.qiitaManager.getEntriesSearch(self.query, page: self.collectionView.page, completion: { (items, isError) -> Void in
            self.collectionView.loadedItems(items, isError: isError, isAppendable: { (item: EntryEntity) -> Bool in
                return !contains(UserDataManager.sharedInstance.muteUsers, item.postUser.id)
            })
        })
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
        let tapEntry: EntryEntity = self.collectionView.items[tapIndexPath!.row] as EntryEntity
        
        let actions: [UIAlertAction] = [
            UIAlertAction(title: "記事詳細", style: .Default, handler: { (UIAlertAction) -> Void in
                self.moveEntryDetail(tapEntry)
            }),
            UIAlertAction(title: tapEntry.postUser.displayName, style: .Default, handler: { (UIAlertAction) -> Void in
                self.moveUserDetail(tapEntry.postUser.id)
            }),
            UIAlertAction(title: "キャンセル", style: .Cancel, handler: { (UIAlertAction) -> Void in
                
            })
        ]
        
        // TODO: そのほかメニュー表示 (記事をストックしているユーザーリスト)
        NSNotificationCenter.defaultCenter()
            .postNotificationName(QCKeys.Notification.ShowActionSheet.rawValue,
                object: nil,
                userInfo: [
                    QCKeys.ActionSheet.Title.rawValue: tapEntry.title + " " + tapEntry.postUser.displayName,
                    QCKeys.ActionSheet.Description.rawValue: tapEntry.beginning,
                    QCKeys.ActionSheet.Actions.rawValue: actions
                ])
    }
    
    func moveEntryDetail(entry: EntryEntity) {
        let vc: EntryDetailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("EntryDetailVC") as EntryDetailViewController
        vc.displayEntry = entry
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PushViewController.rawValue, object: vc)
    }
    
    func moveUserDetail(userId: String) {
        let vc: UserDetailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("UserDetailVC") as UserDetailViewController
        vc.displayUserId = userId
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.PushViewController.rawValue, object: vc)
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.collectionView.items.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: EntryCollectionViewCell = self.collectionView.dequeueReusableCellWithReuseIdentifier("CELL", forIndexPath: indexPath) as EntryCollectionViewCell
        
        let entry: EntryEntity = self.collectionView.items[indexPath.row] as EntryEntity
        cell.display(entry)
        
        return cell
        
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if self.collectionView.page != NSNotFound && (indexPath.row + 1) >= self.collectionView.items.count {
            self.load()
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let tapEntry: EntryEntity = self.collectionView.items[indexPath.row] as EntryEntity
        self.moveEntryDetail(tapEntry)
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width: CGFloat = (self.view.frame.size.width - 3.0) / 2.0
        return CGSize(width: width, height: width)
    }

}
