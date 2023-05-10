//
//  FileManager+loadJSONs.swift
//  FindWay
//
//  Created by Oleksandr Haidaiev on 24.03.2023.
//

import Foundation

#if DEBUG
enum JSONFiles {
    enum FakeConnections: String {
        /// Original data
        case `default` = "connections"
        // London -> Tokyo: 220 (Best)
        // London -> New York -> Los Angeles -> Tokyo: 400+120+150 = 670
        
        // London2 -> Tokyo: 700
        // London2 -> New York -> Los Angeles -> Tokyo: 400+120+150 = 670 (Best)
        
        // TODO: add to JSON
        // Tokyo -> Cape Town -> London: 250+800 = 1050 (Best)
        // Tokyo -> Sydney -> Cape Town -> London: 100+200+800 = 1100
        /// London <-> Tokyo. Check comments for details
        case londonTokyo = "connectionsLondonTokyo"
        // London -> Porto
        // Tokyo -> Sydney
        /// Only 2 isolated connections
        case isolated = "connectionsIsolated"
    }
    enum FakeConnectionDetails: String {
        case londonTokyo = "TODO"
    }
}
#endif

extension FileManager {
    static func loadJSONFromBundle<T: Decodable>(_ name: String) -> T? {
        guard let path = Bundle.main.path(forResource: name, ofType: "json") else {
            assertionFailure("Invalid filename or path")
            return nil
        }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let entity = try JSONDecoder().decode(T.self, from: data)
            return entity
        } catch let error {
            assertionFailure("Error decoding JSON: \(error)")
            return nil
        }
    }
}
