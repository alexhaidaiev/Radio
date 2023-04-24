//
//  AppState+setup.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 21.04.2023.
//

import Foundation

extension AppState {
    static func `default`(environment: Environment = .debug,
                          settings: Settings = .defaultSettings,
                          remoteConfig: RemoteConfiguration = .emptyAwaitingToReceiveRemoteConf,
                          debugFeatures: DebugFeatures = .defaultDisabledAll) -> Self {
        let urlConfig: URLSessionConfiguration = .default
        urlConfig.timeoutIntervalForRequest = 30
        urlConfig.timeoutIntervalForResource = 30
        let urlSession = URLSession(configuration: urlConfig)
        let queryParams: [URLQueryItem] = [
            .renderAsJson,
            .language(settings.languageCode)
        ]
        
        return AppState(environment: environment,
                        network: .init(urlSession: urlSession, commonQueryParameters: queryParams),
                        settings: settings,
                        remoteConfig: remoteConfig,
                        debugFeatures: debugFeatures)
    }
}

extension AppState.Settings {
    static var defaultSettings: Self = .init(languageCode: language,
                                             isDarkMode: systemIsDarkMode)
    private static var language: String { Locale.current.language.languageCode?.identifier ?? "en" }
}

extension AppState.RemoteConfiguration {
    static var emptyAwaitingToReceiveRemoteConf: Self = .init(
        termsAndConditionsLink: URL(string: ""),
        signInPasswordRegex: ""
    )
#if DEBUG
    static var fakeRemoteConf: Self = .init(
        termsAndConditionsLink: URL(string: "https://policies.google.com/terms")!,
        signInPasswordRegex: "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d]{8,}$"
    )
#endif
}

extension AppState.DebugFeatures {
    static var defaultDisabledAll: Self = AppState.DebugFeatures()
#if DEBUG
    static var forSwiftUI: Self = AppState.DebugFeatures(isOfflineMode: true)
    static var forTests: Self = forSwiftUI
#endif
}
