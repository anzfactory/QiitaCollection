//
//  NavigationTitleView.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/06/23.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit
import DTIActivityIndicator

class NavigationTitleView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    var indicatorView: DTIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    deinit {
        let center = NSNotificationCenter.defaultCenter()
        center.removeObserver(self)
    }
    
    private func setup() {
        
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: "startIndicator", name: QCKeys.Notification.ShowLoadingWave.rawValue, object: nil)
        center.addObserver(self, selector: "stopIndicator", name: QCKeys.Notification.HideLoadingWave.rawValue, object: nil)
        
        self.titleLabel.font = UIFont(name: "07LightNovelPOP", size: 16.0)
        self.titleLabel.textColor = UIColor.textLight()
        
        self.indicatorView = DTIActivityIndicatorView(frame:CGRect(x:0, y: 0, width: 60, height: 40))
        self.indicatorView.center = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5)
        self.addSubview(self.indicatorView)
        self.indicatorView.backgroundColor = UIColor.clearColor()
        self.indicatorView.indicatorColor = UIColor.textLight()
        self.indicatorView.indicatorStyle = "wave"
        self.indicatorView.addConstraintHeight(40)
        self.indicatorView.addConstraintWidth(60)
        self.indicatorView.addConstraintCenteringXY()
        self.indicatorView.hidden = true
        
    }
    
    func setTitleText(title: String) {
        self.titleLabel.text = title
    }
    
    func startIndicator() {
        self.indicatorView.hidden = false
        self.titleLabel.hidden = !self.indicatorView.hidden
        self.indicatorView.startActivity()
    }
    
    func stopIndicator() {
        self.indicatorView.stopActivity()
        self.indicatorView.hidden = true
        self.titleLabel.hidden = !self.indicatorView.hidden
    }
}
