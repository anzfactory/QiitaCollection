//
//  App.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/04/05.
//  Copyright (c) 2015年 anz. All rights reserved.
//


public struct App {
    
    enum Setting: String {
        case
        ID = "973532800"

    }

    enum URL {
        case
        Review,
        Wiki
        
        func string() -> String {
            switch self {
            case .Review:
                return "itms-apps://itunes.apple.com/app/id" + App.Setting.ID.rawValue
            case .Wiki:
                return "https://github.com/anzfactory/QiitaCollection/wiki"
            }
        }
    }
    
}
