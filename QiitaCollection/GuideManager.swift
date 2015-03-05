//
//  GuideManager.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/03/01.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import Foundation

class GuideManager: NSObject, CMPopTipViewDelegate {
    
    enum GuideType: Int {
        case
        None,
        SearchIcon,
        EntryCollectionCell,
        SearchConditionSaveIcon,
        SearchConditionView,
        SearchConditionSwaipeCell,
        BackTopGesture,
        MuteListSwaipeCell,
        PinListSwaipeCell,
        QueryListSwipeCell,
        PublicContextMenu
        
        func message() -> String {
            switch self {
            case .SearchIcon:
                return "投稿の検索はこちらから"
            case .EntryCollectionCell:
                return "タップで投稿詳細を閲覧できます。長押しするとメニューが表示されます"
            case .SearchConditionSaveIcon:
                return "検索条件を保存することができます。保存するとトップ画面に常に表示されるようになります"
            case .SearchConditionView:
                return "\"return\"で検索条件を複数指定することができます"
            case .BackTopGesture:
                return "タイトルをタップするとトップ画面に戻ることができます"
            case .SearchConditionSwaipeCell:
                fallthrough
            case .MuteListSwaipeCell:
                fallthrough
            case .PinListSwaipeCell:
                fallthrough
            case .QueryListSwipeCell:
                return "左にスワイプすると削除ボタンが表示されます"
            case .PublicContextMenu:
                return "画面毎の各種メニューが表示されます"
            case .None:
                fallthrough
            default:
                return ""
            }
        }
        
        func guideDirection() -> PointDirection {
            switch self {
            case .SearchConditionView:
                return PointDirection.Up
            default:
                return PointDirection.Down
            }
        }
    }
    
    // シングルトンパターン
    class var sharedInstance : GuideManager {
        struct Static {
            static let instance : GuideManager = GuideManager()
        }
        return Static.instance
    }
    
    var guideType: GuideType = .None
    var displayGuideList: [CMPopTipView] = [CMPopTipView]()
    
    override init() {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receiveClearGuide", name: QCKeys.Notification.ClearGuide.rawValue, object: nil)
    }
        
    func start(type: GuideType, target: UIView, inView:UIView) {
        
        self.guideType = type
        
        if !self.isAvailableGuide() {
            return
        }
        
        let guide:CMPopTipView = self.makeGuide()
        guide.presentPointingAtView(target, inView: inView, animated: true)
        guide.preferredPointDirection = self.guideType.guideDirection()
        self.afterShow(guide)
    }
    
    func start(type: GuideType, target: UIBarButtonItem) {
        
        self.guideType = type
        
        if !self.isAvailableGuide() {
            return
        }
        
        let guide: CMPopTipView = self.makeGuide()
        guide.presentPointingAtBarButtonItem(target, animated: true)
        guide.preferredPointDirection = self.guideType.guideDirection()
        self.afterShow(guide)
    }
    
    func isAvailableGuide() -> Bool {
        if self.guideType == .None {
            return false
        }
        
        if UserDataManager.sharedInstance.isDisplayedGuide(self.guideType.rawValue) {
            return false
        }
        
        return true
    }
    
    func makeGuide() -> CMPopTipView {
        let guide:CMPopTipView = CMPopTipView(message: self.guideType.message())
        
        guide.delegate = self
        return guide
    }
    
    func afterShow(guide: CMPopTipView) {
        UserDataManager.sharedInstance.appendDisplayedGuide(self.guideType.rawValue)
        self.displayGuideList.append(guide)
    }
    
    // MARK: Notification
    func receiveClearGuide() {
        if self.displayGuideList.count == 0 {
            return
        }
        
        for guide in self.displayGuideList {
            guide.dismissAnimated(false)
        }
        self.displayGuideList.removeAll(keepCapacity: false)
    }
    
    // MARK: CMPopTipViewDelegate
    func popTipViewWasDismissedByUser(popTipView: CMPopTipView!) {
        self.displayGuideList.removeObject(popTipView)
    }
}