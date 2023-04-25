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
    var remoteConfig: RemoteConfiguration // empty at start and must be filled before main content
    var debugFeatures: DebugFeatures
    
    var sharedData: SharedData
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
    
    struct DebugFeatures: Equatable {
        // NOTE: all features should be off by default
#if DEBUG
        var isOfflineMode = false
#else
        let isOfflineMode = false
#endif
    }
    
    struct SharedData: Equatable {
        struct Auth: Equatable {
            let token: String
            // etc
        }
        
        struct User: Equatable {
            let userId: UUID
            let name: String
            var country: String?
            // etc
        }
        
        struct AudioPlayerData: Equatable {
            var isPlaying = false
            var itemToPlay: Model.SearchDataAudioItem?
        }
        
        var authData: Auth?
        var userData: User?
        var audioPlayerData: AudioPlayerData
    }
}
