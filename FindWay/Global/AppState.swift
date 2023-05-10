//
//  AppState.swift
//  FindWay
//
//  Created by Oleksandr Haidaiev on 26.03.2023.
//

import Foundation

struct AppState: Equatable {
    var urlSession: URLSession
    var environment: Environment
    var settings: Settings // TODO: save to UserDefaults
    var remoteConfig: RemoteConfiguration // TODO: save to some cache
    var debugConfig: DebugConfig // TODO: save to UserDefaults
    // ... etc
}

extension AppState {
    enum Environment: Equatable {
        case debug, qa, prod
        
        var baseURL: String {
            switch self {
            case .debug: return "https://raw.githubusercontent.com/" // TODO: move to plist, etc
            case .qa: return "https://qa.raw.githubusercontent.com/"
            case .prod: return "https://prod.raw.githubusercontent.com/"
            }
        }
        var description: String {
            switch self {
            case .debug: return "Debug"
            case .qa: return "QA"
            case .prod: return "Prod"
            }
        }
        // ... etc
    }
    
    struct Settings: Equatable {
        var languageCode: String
        var isDarkMode: Bool
    }
    
    /// Parameters that we receive from BA (e.g during app launch)
    struct RemoteConfiguration: Equatable {
        struct Currency: Equatable {
            let symbol: String
            let description: String
        }
        
        let currency: Currency
        // ... validation rules, settings, constants, etc
    }
    
#if DEBUG
    /// Parameters that we use for debugging/testing/emulation  and which we can change (e.g from DebugMenu)
    struct DebugConfig: Equatable {
        // NOTE: all properties must be false be default
        var isUseFakeConnections = false
    }
#endif
}

// MARK: default & mock values

extension Store where Value == AppState {
    static var defaultStore: Store<AppState> { Store(.default()) }
}

extension AppState {
    static func `default`(environment: Environment = .debug,
                          settings: Settings = .defaultSettings,
                          remoteConfig: RemoteConfiguration = .emptyRemoteConf,
                          debugConfig: DebugConfig = .debug) -> Self {
        let urlConfig: URLSessionConfiguration = .default
        urlConfig.timeoutIntervalForRequest = 30
        urlConfig.timeoutIntervalForResource = 30
        return AppState(urlSession: .init(configuration: urlConfig),
                 environment: environment,
                 settings: settings,
                 remoteConfig: remoteConfig,
                 debugConfig: debugConfig)
    }
}

extension AppState.Settings {
    static var defaultSettings: Self = .init(languageCode: language,
                                             isDarkMode: sytemIsDarkMode)
    private static var language: String { Locale.current.language.languageCode?.identifier ?? "en" }
}

extension AppState.RemoteConfiguration {
    static var emptyRemoteConf: Self = .init(currency: .init(symbol: "•", description: "Curr"))
#if DEBUG
    static var fakeRemoteConf: Self = .init(currency: .init(symbol: "≈$", description: "≈USD"))
#endif
}

#if DEBUG
extension AppState.DebugConfig {
    static var debug: Self = AppState.DebugConfig(isUseFakeConnections: true)
    static var disabledAll: Self = AppState.DebugConfig()
}
#endif
