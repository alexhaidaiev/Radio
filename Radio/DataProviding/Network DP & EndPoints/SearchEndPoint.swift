//
//  SearchEndPoint.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 19.04.2023.
//

import Foundation

extension RealSearchDataProvider {
    enum SearchEndPoint: RESTEndpoint {
        case byCategory(_ category: String)
        case byId(_ id: String)
        
        var responseType: APIResponse.Type {
            switch self {
            case .byCategory: return APIModel.SearchRoot.self
            case .byId: return APIModel.SearchRoot.self
            }
        }
        
        var path: String { "Browse.ashx" }
        
        var queryParameters: [QueryParameter] {
            switch self {
            case .byCategory(let category):
                return [.init(name: "c", value: category)]
            case .byId(let id):
                return [.init(name: "id", value: id)]
            }
        }
    }
}

extension APIModel {
    struct SearchRoot: APIResponse {
        let head: Head
        let body: [SearchContent]
    }
    
    struct SearchContent: Codable {
        let key: String?
        let children: [SearchItem]?
        
        // `SearchItem` fields:
        let text: String
        let type: String?
        let URL: String?
        let guideId: String?
        
//        let bitrate: String? // sometimes they are Int, TODO: handle later
//        let reliability: String?
        let subtext: String?
        let genreId: String?
        let formats: String?
        let playing: String?
        let playingImage: String?
        let showId: String?
        let item: String?
        let image: String?
        let currentTrack: String?
        let nowPlayingId: String?
        let presetId: String?
        
        let streamType: String?
        let topicDuration: String?
    }
    
    struct SearchItem: Codable {
        let text: String
        let type: String
        let URL: String?
        let guideId: String?
        
//        let bitrate: String?
//        let reliability: String?
        let subtext: String?
        let genreId: String?
        let formats: String?
        let playing: String?
        let playingImage: String?
        let showId: String?
        let item: String?
        let image: String?
        let currentTrack: String?
        let nowPlayingId: String?
        let presetId: String?
        
        let streamType: String?
        let topicDuration: String?
    }
}
