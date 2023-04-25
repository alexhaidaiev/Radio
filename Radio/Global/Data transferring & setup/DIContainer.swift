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
    var dataProvidersFactory: any ADataProvidersFactory
    var audioManager: AudioManager
    
    init(_ appState: Store<AppState>,
         dataProvidersFactory: (any ADataProvidersFactory)? = nil,
         audioManager: AudioManager? = nil) {
        self.appState = appState
        self.dataProvidersFactory = dataProvidersFactory ?? DataProvidersFactory(appState: appState)
        self.audioManager = audioManager ?? AudioManager(appState: appState)
    }
}
