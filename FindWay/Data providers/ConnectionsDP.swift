//
//  ConnectionsDataProvider.swift
//  FindWay
//
//  Created by Oleksandr Haidaiev on 23.03.2023.
//

import Foundation
import Combine

enum ConnectionsDataProviderError: ErrorWithGeneralAPIError, Equatable {
    case general(api: APIError)
    case serviceUnavailable // as an example
    case tooManyRequests // as an example
    // ... other specific errors
}
extension ConnectionsDataProviderError: CustomStringConvertible {
    var description: String {
        switch self {
        case .general(let api): return api.description
        case .serviceUnavailable: return "Service is unavailable, try later"
        case .tooManyRequests: return "Too many requests, wait and try later"
        }
    }
}

protocol ConnectionsDataProvider: DataProvider
where DataProviderError == ConnectionsDataProviderError {
    func getConnections() -> AnyPublisher<Graph, ConnectionsDataProviderError>
}
extension ConnectionsDataProvider {
    static func dataProviderErrorFrom(code: Int, reason: String) -> DataProviderError? {
        switch code {
        case 123 where reason == "someReason": return .serviceUnavailable // as an example
        case 234 where reason == "anotherReason": return .tooManyRequests // as an example
        default: return nil
        }
    }
}

struct RealConnectionsDataProvider: ConnectionsDataProvider, NetworkDataProvider {
    let repository: HTTPWebRepository
    
    func getConnections() -> AnyPublisher<Graph, DataProviderError> {
        return repository
            .performHTTPRequest(ConnectionsEndPoint.getConnections)
            .map { Self.mapApiConnectionsToGraph($0) }
            .mapError { Self.mapErrors($0) }
            .eraseToAnyPublisher()
    }
}

fileprivate extension ConnectionsDataProvider {
    static func mapApiConnectionsToGraph(_ connection: API.Connections) -> Graph {
        var nodes: [Node] = []
        
        var uniqueCitiesFrom: Set<City> = []
        var uniqueCitiesTo: Set<City> = []
        
        // Create and add nodes for each city in the connections and fill uniqueCities
        for road in connection.connections {
            let fromNode = nodes.first(where: {
                $0.city == road.from
            }) ?? Node(city: road.from, cityCoordinates: Coordinates(api: road.coordinates.from))
            let toNode = nodes.first(where: {
                $0.city == road.to
            }) ?? Node(city: road.to, cityCoordinates: Coordinates(api: road.coordinates.to))
            
            // TODO: remove, change to Set
            nodes.removeAll(where: { $0.city == road.from || $0.city == road.to })
            nodes.append(fromNode)
            nodes.append(toNode)
            
            uniqueCitiesFrom.insert(fromNode.city)
            uniqueCitiesTo.insert(toNode.city)
        }
        
        // Create edges and add them to departure nodes
        for road in connection.connections {
            let fromNode = nodes.first(where: { $0.city == road.from })!
            let toNode = nodes.first(where: { $0.city == road.to })!
            let edge = Edge(destination: toNode, distance: road.price)
            
            fromNode.connections.append(edge)
        }
        
        let orderedCitiesFrom = Array(uniqueCitiesFrom)
        let orderedCitiesTo = Array(uniqueCitiesTo)
        return Graph(nodes: nodes,
                     availableFromCities: orderedCitiesFrom,
                     availableToCities: orderedCitiesTo)
        .sortedByCityNames()
    }
}

// MARK: - Fake

import Combine

#if DEBUG
class FakeConnectionsDataProvider: ConnectionsDataProvider {
    var jsonFileToUse: JSONFiles.FakeConnections = .default
    var apiErrorToFailWith: APIError?
    var getConnectionsAPIValue: API.Connections?
    var getConnectionsReturnValue: AnyPublisher<Graph, DataProviderError>? // an emulation example
    var getConnectionsFinished: EmptyClosure? // MARK: change to publisher?
    
    init(jsonFileToUse: JSONFiles.FakeConnections = .default,
         apiErrorToFailWith: APIError? = nil,
         getConnectionsAPIValue: API.Connections? = nil,
         getConnectionsFinished: EmptyClosure? = nil) {
        self.jsonFileToUse = jsonFileToUse
        self.apiErrorToFailWith = apiErrorToFailWith
        self.getConnectionsAPIValue = getConnectionsAPIValue
        self.getConnectionsFinished = getConnectionsFinished
    }

    func getConnections() -> AnyPublisher<Graph, DataProviderError> {
        return getConnectionsReturnValue ?? fakeAPIResponse()
            .fakeAPIDelay
            .map { Self.mapApiConnectionsToGraph($0) }
            .mapError { Self.mapErrors($0) }
            .handleEvents(receiveOutput: { [weak self] _ in
                DispatchQueue.main.async {
                    self?.getConnectionsFinished?()
                }
            }, receiveCompletion: { [weak self] result in
                DispatchQueue.main.async {
                    self?.getConnectionsFinished?()
                }
            })
            .eraseToAnyPublisher()
    }

    // TODO: extract common code
    private func fakeAPIResponse() -> AnyPublisher<API.Connections, APIError> {
        if let apiErrorToFailWith = apiErrorToFailWith {
            return Fail<API.Connections, APIError>(error: apiErrorToFailWith)
                .eraseToAnyPublisher()
        } else {
            return Just(getConnectionsAPIValue ?? .fakeConnections(from: jsonFileToUse))
                .setFailureType(to: APIError.self)
                .eraseToAnyPublisher()
        }
    }
    
    static func fakeGraph(from: JSONFiles.FakeConnections = .default) -> Graph? {
        return Self.mapApiConnectionsToGraph(.fakeConnections(from: from))
    }
}

extension ConnectionsDataProvider where Self == FakeConnectionsDataProvider {
    static var fakeConnectionsDataProvider: Self { FakeConnectionsDataProvider() }
}

// MARK: Testing

protocol ConnectionsDataProviderPrivateTesting where Self: ConnectionsDataProvider { }
extension ConnectionsDataProviderPrivateTesting {
    static func privateMapApiConnectionsToGraph(_ connection: API.Connections) -> Graph {
        return mapApiConnectionsToGraph(connection)
    }
}
#endif
