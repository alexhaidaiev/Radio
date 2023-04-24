//
//  DebugConst.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 24.04.2023.
//

import Foundation

#if DEBUG
extension URL {
    enum ForDebug {
        enum Browse: String {
            case sportsCategory = "https://opml.radiotime.com/Browse.ashx?c=sports"
            case musicWorldMix  = "https://opml.radiotime.com/Browse.ashx?id=g22"
        }
    }
    
    static func forDebug(_ type: ForDebug.Browse) -> URL {
        URL(string: type.rawValue)!
    }
}
#endif
