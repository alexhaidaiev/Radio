//
//  AppState.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 16.04.2023.
//

import Foundation

struct AppState: Equatable {
    var environment: Environment
    var network: Network
    var settings: Settings
    var remoteConfig: RemoteConfiguration
    var debugFeatures: DebugFeatures
}

extension AppState {
    struct Network: Equatable {
        var urlSession: URLSession
        var commonQueryParameters: [RESTEndpoint.QueryParameter]
    }
    
    enum Environment: Equatable {
        case debug, qa, prod
        
        var baseURL: String {
            switch self {
            case .debug: return "https://opml.radiotime.com/"
            case .qa: return "https://qa.opml.radiotime.com/"
            case .prod: return "https://prod.opml.radiotime.com/"
            }
        }
    }
    
    struct Settings: Equatable {
        var languageCode: String
        var isDarkMode: Bool
    }
    
    struct RemoteConfiguration: Equatable {
        let termsAndConditionsLink: URL?
        let signInPasswordRegex: String
    }
    
#if DEBUG
    struct DebugFeatures: Equatable {
        // NOTE: all features should be off by default
        var isOfflineMode = false
    }
#endif
}
