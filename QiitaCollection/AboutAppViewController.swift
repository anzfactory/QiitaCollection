//
//  AboutAppViewController.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/03/04.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class AboutAppViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: UI
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var tableView: BaseTableView!
    
    // MARK: プロパティ
    lazy var aboutAppInfo: NSArray = self.readPlist()

    // MARK: ライフサイクル
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupForPresentedVC(self.navigationBar)
        
        self.tableView.separatorColor = UIColor.borderTableView()
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: Actions
    @IBAction func tapClose(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }
    
    // MARK: メソッド
    func readPlist() -> NSArray {
        let filePath: String = NSBundle.mainBundle().pathForResource("AboutApp", ofType: "plist")!
        let aboutAppInfo: NSArray = NSArray(contentsOfFile: filePath)!
        return aboutAppInfo
    }
    
    func findSectionTitle(section: Int) -> String {
        if let itemsInSection: NSDictionary = self.aboutAppInfo[section] as? NSDictionary {
            return itemsInSection.allKeys[0] as String
        }
        return ""
    }
    
    func findItems(section: Int) -> NSArray {
        if let itemsInSection: NSDictionary = self.aboutAppInfo[section] as? NSDictionary {
            
            let key: String = itemsInSection.allKeys[0] as String
            return itemsInSection[key] as NSArray
            
        }
        println(" not find..... ")
        return NSArray()
    }
    
    // MARK: UITableViewDatasSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.aboutAppInfo.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.findItems(section).count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: AdjustTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("CELL") as AdjustTableViewCell
        
        let items: NSArray = self.findItems(indexPath.section)

        if indexPath.section == 0 {
            let abountQC = (items[indexPath.row] as NSDictionary).allValues[0] as? String ?? ""
            cell.title.textAlignment = .Left
            cell.title.font = UIFont(name: "07LogoTypeGothic7", size: 14.0)
            cell.title.text = abountQC.stringByReplacingOccurrencesOfString("[BR]", withString: "\n", options: nil, range: nil)
        } else {
            cell.title.text = (items[indexPath.row] as NSDictionary).allKeys[0] as? String ?? ""
        }
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 21
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let height: CGFloat = 21
        let titleLabel: UILabel = UILabel(frame: CGRect(x: 8, y: 0, width: self.tableView.bounds.size.width - 16, height: height))
        titleLabel.numberOfLines = 1
        titleLabel.font = UIFont.boldSystemFontOfSize(14)
        titleLabel.text = self.findSectionTitle(section)
        titleLabel.sizeToFit()
        
        let header: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: height))
        header.addSubview(titleLabel)
        header.backgroundColor = UIColor.backgroundSub(0.8)
        return header
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 0 {
            return
        }
        
        let items: NSArray = self.findItems(indexPath.section)
        if let item: NSDictionary = items[indexPath.row] as? NSDictionary {
            let urlString: String = item.allValues[0] as String
            if urlString.isEmpty {
                return
            }
            UIApplication.sharedApplication().openURL(NSURL(string: urlString)!)
        }
    }
}
