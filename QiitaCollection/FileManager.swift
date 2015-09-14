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
            
            var isError: Bool = true
            do {
                try dataString.writeToFile(fullPath, atomically: false, encoding:NSUTF8StringEncoding)
                isError = false
            } catch {
                
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completion(isError: isError)
            })
            
        })
    }
    
    func read(fileName: String, completion: (text: String) -> Void) {
        let fullPath: String = self.fileFullPath(fileName)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            
            var result = ""
            do {
                result = try String(contentsOfFile: fullPath, encoding: NSUTF8StringEncoding)
            } catch {
                
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
               completion(text: result)
            })
            
        })
        
    }
    
    func remove(fileName: String, completion: (isError: Bool) -> Void) {
        let fullPath: String = self.fileFullPath(fileName)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            let fileMam = NSFileManager()
            var isError = true
            
            do {
                try fileMam.removeItemAtPath(fullPath)
                isError = false
            } catch {
                
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completion(isError: isError)
            })
            
        })
    }
    
    
    func fileFullPath(fileName: String) -> String {
        let directoryPath: String = NSSearchPathForDirectoriesInDomains(
            NSSearchPathDirectory.DocumentDirectory,
            NSSearchPathDomainMask.UserDomainMask,
            true
            )[0]
        
        let fullPath: String = NSString(string: directoryPath).stringByAppendingPathComponent(fileName)
        return fullPath
    }
    
}