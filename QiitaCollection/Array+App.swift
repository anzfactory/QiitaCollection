//
//  Array+App.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/22.
//  Copyright (c) 2015年 anz. All rights reserved.
//

extension Array {
    mutating func removeObject<E: Equatable>(object: E) -> Array {
        for var i = 0; i < self.count; i++ {
            if self[i] as E == object {
                self.removeAtIndex(i)
                break
            }
        }
        return self
    }
    
    static func convert(dict: [[String: String]], key: String) -> [T] {
        var result: [T] = [T]()
        for item in dict {
            if let keyValue = item[key] {
                if keyValue is T {
                    result.append(keyValue as T)
                }
            }
        }
        return result
    }
}
