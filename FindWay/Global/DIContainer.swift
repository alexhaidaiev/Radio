//
//  DIContainer.swift
//  FindWay
//
//  Created by Oleksandr Haidaiev on 01.04.2023.
//

import Foundation

struct DIContainer {
    var appState: Store<AppState>
    var dataProviderFactory: DataProviderFactory
    
    init(_ appState: Store<AppState>) {
        self.appState = appState
        self.dataProviderFactory = DataProviderFactory(appState: appState)
    }
}

extension DIContainer {
    static var real: Self { .init(Store(.default(environment: .prod,
                                                 debugConfig: .disabledAll))) }
#if DEBUG
    static var mocked: Self { .init(.defaultStore) }
    static var mockedSwiftUI: Self { .init(Store(.default(remoteConfig: .fakeRemoteConf))) }
    static var mockedTests: Self { .init(Store(.default(remoteConfig: .fakeRemoteConf))) }
#endif
}
