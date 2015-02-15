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
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: プロパティ
    var entries: [EntryEntity] = []
    var page: Int = 0
    var qiitaManager: QiitaApiManager = QiitaApiManager()
    
    // MARK: ライフサイクル
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longPressGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "longPress:")
        self.collectionView.addGestureRecognizer(longPressGesture)
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        refresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: メソッド
    func refresh() {
        self.page = 1
        self.load()
    }
    func load() {
        self.qiitaManager.getEntriesNew(self.page, completion: { (items, isError) -> Void in
            
            if isError {
                println("error")
                // TODO: アラートなりトーストなりでユーザー通知 (リトライとか？)
                return
            }
            
            if items.count == 0 {
                self.page = NSNotFound      // オートページング止めるために
                return
            } else if (self.page == 1) {
                // リフレッシュ対象なのでリストクリア
                self.entries.removeAll(keepCapacity: false)
            }
            
            for item: EntryEntity in items {
                self.entries.append(item)
            }
            self.page++
            self.collectionView.reloadData()
        })
    }
    
    func longPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state != UIGestureRecognizerState.Began {
            return
        }
        let tapPoint: CGPoint = gesture.locationInView(self.collectionView)
        let tapIndexPath: NSIndexPath = self.collectionView.indexPathForItemAtPoint(tapPoint)!
        let tapEntry: EntryEntity = self.entries[tapIndexPath.row]
        
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
        
        // TODO: そのほかメニュー表示
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
        return self.entries.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: EntryCollectionViewCell = self.collectionView.dequeueReusableCellWithReuseIdentifier("CELL", forIndexPath: indexPath) as EntryCollectionViewCell
        
        let entry: EntryEntity = self.entries[indexPath.row]
        cell.display(entry)
        
        return cell
        
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if self.page != NSNotFound && (indexPath.row + 1) >= self.entries.count {
            self.load()
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let tapEntry: EntryEntity = self.entries[indexPath.row]
        self.moveEntryDetail(tapEntry)
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width: CGFloat = (self.view.frame.size.width - 3.0) / 2.0
        return CGSize(width: width, height: width)
    }

}
