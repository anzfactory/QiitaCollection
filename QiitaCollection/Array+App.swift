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
}
