//
//  DIContainer+setup.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 22.04.2023.
//

extension DIContainer {
    static var real: Self {
        .init(Store(.default(environment: .prod,
                             debugFeatures: .defaultDisabledAll)))
    }
#if DEBUG
    static var debug: Self {
        .init(Store(.default()))
    }
    static var mockedSwiftUI: Self {
        .init(Store(.default(remoteConfig: .fakeRemoteConf,
                             debugFeatures: .forSwiftUI)))
    }
    static var mockedTests: Self {
        .init(Store(.default(remoteConfig: .fakeRemoteConf,
                             debugFeatures: .forTests)))
    }
#endif
}
