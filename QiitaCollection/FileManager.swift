//
//  FileManager.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/28.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class FileManager {
    
    func save(fileName: String, dataString:String, completion: (isError: Bool) -> Void) {
        
        let fullPath: String = self.fileFullPath(fileName)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            var error: NSError? = nil
            let result = dataString.writeToFile(fullPath, atomically: false, encoding:NSUTF8StringEncoding, error: &error)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completion(isError: (!result || error != nil))
            })
            
        })
    }
    
    func read(fileName: String, completion: (text: String) -> Void) {
        let fullPath: String = self.fileFullPath(fileName)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            var error: NSError? = nil
            let result = String(contentsOfFile: fullPath, encoding: NSUTF8StringEncoding, error: &error) ?? ""
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
               completion(text: result)
            })
            
        })
        
    }
    
    func remove(fileName: String, completion: (isError: Bool) -> Void) {
        let fullPath: String = self.fileFullPath(fileName)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            var error: NSError? = nil
            let fileMam = NSFileManager()
            let result = fileMam.removeItemAtPath(fullPath, error: &error)
            
            if let e = error {
                println(e)
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completion(isError: (!result || error != nil))
            })
            
        })
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