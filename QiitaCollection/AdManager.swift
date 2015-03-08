//
//  AdManager.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/03/08.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import Foundation

class AdManager: NSObject, GADInterstitialDelegate {
    
    // シングルトンパターン
    class var sharedInstance : AdManager {
        struct Static {
            static let instance : AdManager = AdManager()
        }
        return Static.instance
    }
    
    var interstitial: GADInterstitial? = nil
    var isDisplayedInterstitial: Bool = false
    
    override init() {
        super.init()
    }
    
    func setupInterstitial() {
        self.interstitial = GADInterstitial()
        self.interstitial!.adUnitID = ThirdParty.AdMob.AdUnitID.rawValue
        self.interstitial!.delegate = self
        self.interstitial!.loadRequest(GADRequest())
    }
    
    func showInterstitial(vc: UIViewController) {
        if let ad = self.interstitial {
            if ad.isReady && !self.isDisplayedInterstitial {
                ad.presentFromRootViewController(vc)
            }
        } else {
            // 次回に備えてセットアップを試みておく
            self.setupInterstitial()
        }
    }
    
    // MARK: GADInterstitialDelegate
    func interstitial(ad: GADInterstitial!, didFailToReceiveAdWithError error: GADRequestError!) {
        self.isDisplayedInterstitial = false
    }
    func interstitialWillPresentScreen(ad: GADInterstitial!) {
        self.isDisplayedInterstitial = true
    }
    
    func interstitialDidDismissScreen(ad: GADInterstitial!) {
        self.isDisplayedInterstitial = false
        // 次回に備えてセットアップを試みておく
        self.setupInterstitial()
    }
    
    // 広告タップで遷移したとき
    func interstitialWillLeaveApplication(ad: GADInterstitial!) {
        
    }
}