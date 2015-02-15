//
//  EntryDetailView.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/14.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

// MEMO: TapGestureにも対応したいのでサブクラス作成
class ANZContextSheet: VLDContextSheet {
    
    // MARK: プロパティ
    var isShownContextMenu: Bool = false
    
    // MARK: オーバーライド
    override func startWithGestureRecognizer(gestureRecognizer: UIGestureRecognizer!, inView view: UIView!) {

        /* この処理のスーパークラスの中身
        - (void) startWithGestureRecognizer: (UIGestureRecognizer *) gestureRecognizer inView: (UIView *) view {
        [view addSubview: self];
        
        self.frame = VLDOrientedScreenBounds();
        [self createZones];
        
        self.starterGestureRecognizer = gestureRecognizer;
        
        self.touchCenter = [self.starterGestureRecognizer locationInView: self];
        self.centerView.center = self.touchCenter;
        self.selectedItemView = nil;
        [self setCenterViewHighlighted: YES];
        self.rotation = [self rotationForCenter: self.centerView.center];
        
        [self openItemsFromCenterView];
        
        // こいつだけを変えたい
        [self.starterGestureRecognizer addTarget: self action: @selector(gestureRecognizedStateObserver:)];
        }
        */
        
        if self.isShownContextMenu {
            return
        }
        self.isShownContextMenu = true
        
        super.startWithGestureRecognizer(gestureRecognizer, inView: view)
        
        // ジェスチャを取り消し
        gestureRecognizer.removeTarget(self, action: "gestureRecognizedStateObserver:")
    
    }
    
    override func end() {
        self.isShownContextMenu = false
        super.end()
    }
    
}

class EntryDetailView: UIWebView, UIGestureRecognizerDelegate, VLDContextSheetDelegate {
    
    
    // MARK: プロパティ
    lazy var contextSheet: ANZContextSheet = self.makeContextMenu()

    let menuTitleShare: String = "Share"
    let menuTitleLinks: String = "Links"
    let menuTitleClipboard: String = "ClipBoard"
    var callbackSelectedMenu: ((VLDContextSheetItem)->Void)?

    // MARK: ライフサイクル
    
    override func awakeFromNib() {
        let longTapGesture = UITapGestureRecognizer(target: self, action: "tapView:")
        longTapGesture.delegate = self;
        self.addGestureRecognizer(longTapGesture)
        
        self.contextSheet.delegate = self
    }
    
    
    // MARK: メソッド
    
    func makeContextMenu() -> ANZContextSheet {
        let menuItemShare: VLDContextSheetItem = VLDContextSheetItem(title: self.menuTitleShare, image:UIImage(named: "icon_share") , highlightedImage: nil)
        let menuItemLinks: VLDContextSheetItem = VLDContextSheetItem(title: self.menuTitleLinks, image: UIImage(named: "icon_link"), highlightedImage: nil)
        let menuItemClipboard: VLDContextSheetItem = VLDContextSheetItem(title: self.menuTitleClipboard, image: UIImage(named: "icon_clipboard"), highlightedImage: nil)
        return ANZContextSheet(items: [menuItemShare, menuItemLinks, menuItemClipboard])
    }
    
    func tapView(gesture: UILongPressGestureRecognizer) {
        if (self.contextSheet.isShownContextMenu) {
            self.contextSheet.updateItemViewsForTouchPoint(gesture.locationInView(self.contextSheet))
            self.contextSheet.end()
        } else {
            self.contextSheet.startWithGestureRecognizer(gesture, inView: self)
        }
    }
    
    // MMARK: UIGestureRecognizerDelegate
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // すべてのジェスチャを認識 (UIWebViewがそもそももってるものと、自分がついかしたものと)
        return true;
    }
    
    
    // MARK: VLDContextSheetDelegate
    
    func contextSheet(contextSheet: VLDContextSheet!, didSelectItem item: VLDContextSheetItem!) {
        self.callbackSelectedMenu?(item)
    }

}
