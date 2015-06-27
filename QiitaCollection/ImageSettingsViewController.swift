//
//  ImageSettingsViewController.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/06/27.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class ImageSettingsViewController: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var controlPanel: UIView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var segmentCoverType: UISegmentedControl!
    @IBOutlet weak var picker: UIButton!
    @IBOutlet weak var coverImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupForPresentedVC(self.navigationBar)
        
        self.controlPanel.backgroundColor = UIColor.backgroundSub()
        self.segmentCoverType.tintColor = UIColor.tintSegmented()
        self.picker.setImage(
            self.picker.imageView?.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate),
            forState: UIControlState.Normal
        )
        self.picker.tintColor = UIColor.tintAttention()
        
        self.setupCoverImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func tapClose(sender: AnyObject) {
        
        // 現在の設定で更新する
        if let image = self.coverImage.image where self.segmentCoverType.selectedSegmentIndex == 0 {
            UserDataManager.sharedInstance.setImageForGridCover(image)
        } else if let image = self.coverImage.image where self.segmentCoverType.selectedSegmentIndex == 1 {
            UserDataManager.sharedInstance.setImageForViewCover(image)
        } else {
            UserDataManager.sharedInstance.clearImageCover()
        }
        NSNotificationCenter.defaultCenter().postNotificationName(QCKeys.Notification.ReloadViewPager.rawValue, object: nil)
        
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }
    
    @IBAction func tapMedia(sender: AnyObject) {
        openImagePicker()
    }
    
    @IBAction func changeCoverType(sender: AnyObject) {
        self.picker.hidden = self.segmentCoverType.selectedSegmentIndex == 2
    }
    
    func setupCoverImage() {
        var index = 2
        var image: UIImage? = nil
        var hidden = false
        if UserDataManager.sharedInstance.hasImageForGridCover() {
            image = UserDataManager.sharedInstance.imageForGridCover()
            index = 0
        } else if UserDataManager.sharedInstance.hasImageForViewCover() {
            image = UserDataManager.sharedInstance.imageForViewCover()
            index = 1
        } else {
            hidden = true
            self.coverImage.hidden = true
        }
        self.segmentCoverType.selectedSegmentIndex = index
        self.coverImage.image = image
        self.picker.hidden = hidden
    }
    
    func openImagePicker() {
        
        if self.segmentCoverType.selectedSegmentIndex > 1 {
            return
        }
        
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)) {
            let picker = UIImagePickerController()
            picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            picker.allowsEditing = self.segmentCoverType.selectedSegmentIndex == 0
            picker.delegate = self
            
            self .presentViewController(picker, animated: true, completion: { () -> Void in
                
            })
        }
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        picker.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.coverImage.hidden = false
            self.coverImage.image = image
        })
    }
    
}
