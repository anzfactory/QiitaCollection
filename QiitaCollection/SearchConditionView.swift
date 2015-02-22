//
//  SearchConditionView.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/22.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

protocol SearchConditionViewDelegate: NSObjectProtocol {
    func searchVC(viewController: SearchConditionView, sender: UIButton)
}

class SearchConditionView: UIView {
    
    enum SearchType: Int {
        case
        All = 0,
        Title,
        Body,
        Code,
        Tag,
        User
        
        func name() -> String {
            switch self {
            case .All: return "すべて"
            case .Title: return "タイトル"
            case .Body: return "本文"
            case .Code: return "コード"
            case .Tag: return "タグ"
            case .User: return "ユーザー"
            default: return ""
            }
        }
        
        func query() -> String {
            switch self {
            case .All: return ""
            case .Title: return "title:"
            case .Body: return "body:"
            case .Code: return "code:"
            case .Tag: return "tag:"
            case .User: return "user:"
            default: return ""
            }
        }
    }
    
    // MARK: UI
    @IBOutlet weak var searchType: UISegmentedControl!
    @IBOutlet weak var excludeLabel: UILabel!
    @IBOutlet weak var excludeCheck: UIButton!
    @IBOutlet weak var query: UITextField!
    @IBOutlet weak var doSearch: UIButton!
    
    // プロパティ
    var delegate: SearchConditionViewDelegate? = nil
    
    // MARK: ライフサイクル
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.backgroundSearchCondition()
        
        self.searchType.tintColor = UIColor.tintSegmented()
        
        self.excludeCheck.layer.borderWidth = 1.0
        self.excludeCheck.layer.cornerRadius = 5.0
        self.excludeCheck.layer.borderColor = UIColor.borderButton().CGColor
        self.excludeCheck.setImage(UIImage(named: "icon_check")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Selected)
        self.excludeCheck.tintColor = UIColor.tintAttention()
        
        self.query.textColor = UIColor.textBase()
                
        self.doSearch.layer.cornerRadius = 5.0
        self.doSearch.backgroundColor = UIColor.backgroundBase()

        self.prepare()
        
    }
    
    // MARK: Actions
    @IBAction func tapSearch(sender: UIButton) {
        self.delegate?.searchVC(self, sender: sender)
    }
    
    @IBAction func tapAdd(sender: UIButton) {
        self.delegate?.searchVC(self, sender: sender)
    }
    
    @IBAction func tapExclude(sender: UIButton) {
        self.excludeCheck.selected = !self.excludeCheck.selected
    }
    
    
    // MARK: メソッド
    func prepare() {
        self.searchType.selectedSegmentIndex = 0
        self.excludeCheck.selected = false
        self.query.text = ""
    }
    
    func clear() {
        self.prepare()
    }
    
}
