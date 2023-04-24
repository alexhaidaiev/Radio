//
//  DIContainer.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 16.04.2023.
//

import Foundation

struct DIContainer {
#if DEBUG
    static let defaultValue: DIContainer = .debug
#else
    static let defaultValue: DIContainer = .real
#endif
    
    var appState: Store<AppState>
    var dataProviderFactory: DataProvidersFactory
    
    init(_ appState: Store<AppState>) {
        self.appState = appState
        self.dataProviderFactory = DataProvidersFactory(appState: appState)
    }
}
