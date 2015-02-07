//
//  EntryCollectionViewCell.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/07.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class EntryCollectionViewCell: UICollectionViewCell {
    
    // MARK:
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    
    func display(entry: EntryEntity) {
        
        // TODO: 背景ロード
        
        self.title.text = entry.title;
        
    }
}
