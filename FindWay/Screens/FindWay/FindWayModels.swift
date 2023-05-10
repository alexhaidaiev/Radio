//
//  Models.swift
//  FindWay
//
//  Created by Oleksandr Haidaiev on 23.03.2023.
//

import Foundation

typealias City = String
extension City: Identifiable {
    public var id: String { self }
}

struct Coordinates: Equatable {
    let x: Double
    let y: Double
}
extension Coordinates {
    init(api: API.Coordinate) {
        self.x = api.long
        self.y = api.lat
    }
}

class Node { // TODO: change to the `struct` and introduce `class NodeContainer { let node: Node }`
    let city: City
    let cityCoordinates: Coordinates
    var connections: [Edge]
    
    init(city: City, cityCoordinates: Coordinates, connections: [Edge] = []) {
        self.city = city
        self.cityCoordinates = cityCoordinates
        self.connections = connections
    }
}

struct Edge {
    let destination: Node
    let distance: Double
}

struct Graph: Equatable {
    let nodes: [Node]
    let availableFromCities: [City]
    let availableToCities: [City]
    
    func getNode(for city: String) -> Node? { nodes.first(where: { $0.city == city }) }
    
    func sortedByCityNames() -> Self {
        return Graph(nodes: nodes.sorted(by: { $0.city < $1.city }),
                     availableFromCities: availableFromCities.sorted(),
                     availableToCities: availableToCities.sorted())
    }
}

struct Trip: Equatable {
    let fromCity: City
    let toCity: City
    let fromCoordinates: Coordinates
    let toCoordinates: Coordinates
    /// When `nil` it means we don't have  tickets available to buy
    let price: Double?
}

// MARK: - Additional Protocols

extension Node: Equatable {
    static func ==(lhs: Node, rhs: Node) -> Bool {
        return lhs.city == rhs.city
    }
}
extension Node: Hashable {
    var hashValue: Int { city.hashValue }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(city)
    }
}

extension Node: CustomStringConvertible {
    var description: String { "'\(city)', has: \(connections.count) connections" }
}

extension Edge: CustomStringConvertible {
    var description: String { "To: '\(destination.city)', cost: \(distance)" }
}

extension Trip: CustomStringConvertible {
    var description: String { "'\(fromCity)' -> '\(toCity)', cost: \(String(describing: price))" }
}

#if DEBUG
extension Graph {
    static var fakeEmpty: Self { .init(nodes: [], availableFromCities: [], availableToCities: []) }
    
    static func fake(from: JSONFiles.FakeConnections = .default) -> Self {
        let dataProvider = FakeConnectionsDataProvider.self
        return dataProvider.fakeGraph(from: from) ?? assertionFailure(toReturn: .fakeEmpty)
    }
    
    // An example of how to use hardcoded values created manually
    @available(*, message: "In most cases it's better to use `fake(from: )` method instead")
    static func fakeHardCodedLondonTokyo(isDirectCostCheaper: Bool) -> Self {
        let londonCoord: Coordinates = .init(x: -0.241681, y: 51.5285582)
        let tokyonCoord: Coordinates = .init(x: 139.839478, y: 35.652832)
        let newYorkCoord: Coordinates = .init(x: -73.935242, y: 40.73061)
        let tokyoDestinationNode = Node(city: "Tokyo", cityCoordinates: tokyonCoord)
        let newYorkDestinationNode = Node(city: "New York", cityCoordinates: tokyonCoord)
        let directCost = 400.0 + (isDirectCostCheaper ? -25 : 0)
        
        return Graph(
            nodes: [
                Node(city: "London", cityCoordinates: londonCoord, connections: [
                    Edge(destination: tokyoDestinationNode, distance: directCost),
                    Edge(destination: newYorkDestinationNode, distance: 300)
                ]),
                Node(city: "New York", cityCoordinates: newYorkCoord, connections: [
                    Edge(destination: tokyoDestinationNode, distance: 100)
                ]),
                Node(city: "Tokyo", cityCoordinates: tokyonCoord, connections: [])
            ],
            availableFromCities: ["London", "New York"],
            availableToCities: ["Tokyo", "New York"])
    }
}
#endif
