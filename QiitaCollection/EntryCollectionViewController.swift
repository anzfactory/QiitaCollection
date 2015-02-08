//
//  EntryCollectionViewController.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/07.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class EntryCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // MARK: UI
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: プロパティ
    var entries: [EntryEntity] = []
    var page: Int = 0
    var qiitaManager: QiitaApiManager = QiitaApiManager()
    
    // MARK: ライフサイクル
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        refresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width: CGFloat = (self.collectionView.frame.size.width - 3.0) / 2.0
        return CGSize(width: width, height: width)
    }

}
