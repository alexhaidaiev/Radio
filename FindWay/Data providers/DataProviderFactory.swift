//
//  DataProviderFactory.swift
//  FindWay
//
//  Created by Oleksandr Haidaiev on 01.04.2023.
//

import Foundation

struct DataProviderFactory {
    let appState: Store<AppState>
    
    func createConnectionsDP() -> any ConnectionsDataProvider {
#if DEBUG
        return DynamicConnectionsDataProvider(appState)
#else
        return Self.createRealConnectionsDP(appState)
#endif
    }
    
    static fileprivate func createRealConnectionsDP(_ appState: Store<AppState>)
    -> RealConnectionsDataProvider {
        let builder = RequestBuilder(baseURL: appState[\.environment].baseURL)
        let repo = HTTPWebRepository(session: appState[\.urlSession], requestBuilder: builder)
        return RealConnectionsDataProvider(repository: repo)
    }
}

#if DEBUG
fileprivate class DynamicConnectionsDataProvider: ConnectionsDataProvider {
    private var current: any ConnectionsDataProvider
    private var cancellable: CancellableContainer = .init()
    
    init(_ appState: Store<AppState>) {
        self.current = Self.createCurrent(appState)
        
        appState.publisher(for: \.debugConfig.isUseFakeConnections)
            .combineLatest(appState.publisher(for: \.environment))
            .sink { [weak self] _, _ in
                self?.current = Self.createCurrent(appState)
            }
            .store(in: cancellable)
    }
    
    func getConnections() -> AnyCombinePublisher<Graph, ConnectionsDataProviderError> {
        current.getConnections()
    }
    
    static private func createCurrent(_ appState: Store<AppState>) -> any ConnectionsDataProvider {
        if appState[\.debugConfig].isUseFakeConnections {
            return .fakeConnectionsDataProvider
        } else {
            return DataProviderFactory.createRealConnectionsDP(appState)
        }
    }
}
#endif
