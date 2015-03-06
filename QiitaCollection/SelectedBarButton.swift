//
//  SelectedBarButton.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/03/06.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class SelectedBarButton: UIBarButtonItem {
   
    var selectedColor: UIColor? = nil
    var originColor: UIColor? = nil
    
    var selected: Bool = false {
        didSet {
            if self.selected {
                if let color = self.selectedColor {
                    self.originColor = self.tintColor
                    self.tintColor = color
                }
            } else {
                self.tintColor = self.originColor
            }
        }
    }
}
