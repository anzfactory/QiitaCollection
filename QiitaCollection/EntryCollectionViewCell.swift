//
//  EntryCollectionViewCell.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/07.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class EntryCollectionViewCell: UICollectionViewCell {
    
    // MARK: UI
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    
    // MARK: メソッド
    func display(entry: EntryEntity) {
        
        // TODO: 背景ロード
        
        self.title.text = entry.title;
        
    }
}
