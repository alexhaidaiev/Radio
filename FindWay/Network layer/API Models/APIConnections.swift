//
//  APIConnections.swift
//  FindWay
//
//  Created by Oleksandr Haidaiev on 24.03.2023.
//

import Foundation

extension API {
    struct Connections: Decodable {
        struct Road: Decodable {
            let from: String
            let to: String
            let price: Double
            let coordinates: Coordinates
        }
        
        let connections: [Road]
    }
}

#if DEBUG
extension API.Connections {
    static var fakeEmpty: Self { .init(connections: []) }
    
    static func fakeConnections(from: JSONFiles.FakeConnections = .default) -> Self {
        FileManager.loadJSONFromBundle(from.rawValue) ?? .fakeEmpty
    }
}
#endif
