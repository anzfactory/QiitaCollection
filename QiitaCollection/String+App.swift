//
//  String+App.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/03/12.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

extension String {
    
    // http://qiita.com/edo_m18/items/54b6d6f5f562df55ac9b
    func removeExceptionUnicode() -> String {
        
        let exceptioUnicodes: [String] = [
            "0900", "0901", "0902", "0903",
            "093a", "093b", "093c", "093e", "093f",
            "0940", "0941", "0942", "0943", "0944", "0945", "0946", "0947", "0948", "0949",
            "094a", "094b", "094c", "094d", "094e", "094f",
            "0953", "0954", "0955", "0956", "0957",
            "0962", "0963"
        ]
        
        let exceptionPattern: NSMutableString = NSMutableString()
        for unicode in exceptioUnicodes {
            exceptionPattern.appendFormat("\\u%@|", unicode)
        }

        let regex: NSRegularExpression = try! NSRegularExpression(pattern: exceptionPattern as String, options: NSRegularExpressionOptions(rawValue: 0))
        
        let target: NSMutableString = NSMutableString(string: self)
        regex.replaceMatchesInString(target, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, target.length), withTemplate: "")
        
        return String(target)
    }
    
}