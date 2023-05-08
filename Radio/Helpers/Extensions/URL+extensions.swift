//
//  URL+extensions.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 24.04.2023.
//

import Foundation

extension URL {
    public var queryParameters: [String: String]? {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
    
    public static func + (left: URL, right: String) -> URL {
        left.appending(path: right)
    }
}
