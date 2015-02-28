//
//  FileManager.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/28.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class FileManager {
    
    func save(fileName: String, dataString:String) -> Bool {
        
        let fullPath: String = self.fileFullPath(fileName)
        
        var error: NSError? = nil
        let result = dataString.writeToFile(fullPath, atomically: false, encoding:NSUTF8StringEncoding, error: &error)
        
        if !result || error != nil {
            return false
        }
        
        return true
    }
    
    func read(fileName: String) -> String {
        let fullPath: String = self.fileFullPath(fileName)
        var error: NSError? = nil
        let result = String(contentsOfFile: fullPath, encoding: NSUTF8StringEncoding, error: &error)
        return result ?? ""
    }
    
    
    func fileFullPath(fileName: String) -> String {
        let directoryPath: String = NSSearchPathForDirectoriesInDomains(
            NSSearchPathDirectory.DocumentDirectory,
            NSSearchPathDomainMask.UserDomainMask,
            true
            )[0] as String
        
        let fullPath: String = directoryPath.stringByAppendingPathComponent(fileName)
        return fullPath
    }
    
}