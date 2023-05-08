//
//  SearchDataItems.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 21.04.2023.
//

import Foundation

protocol ModelSearchDataItem: Codable, Identifiable, Hashable, Equatable {
    typealias ItemType = Model.SearchDataItemType
    var id: ModelID { get }
    
    var text: String { get }
    var url: URL? { get }
    var type: ItemType { get }
    var guideID: String { get }
}

extension Model {
    enum SearchDataItemType: String, Codable {
        case link, audio, text, unknown
    }
    
    struct SearchDataAudioItem: ModelSearchDataItem {
        private(set) var id = ModelID()
        
        // all
        let text: String
        let url: URL?
        let type: ItemType
        let guideID: String
        
        // stations, topics
        let subtext: String?
        let item: String?
        let image: String?
        let currentTrack: String?
        let nowPlayingID: String?
        
        // stations
//        let bitrate: String?
//        let reliability: String?
        let genreID: String?
        let formats: String?
        let playing: String?
        let playingImage: String?
        let showID: String?
        let presetID: String?
        
        // topics
        let streamType: String?
        let topicDuration: String?
    }
    
    struct SearchDataLinkItem: ModelSearchDataItem {
        private(set) var id = ModelID()
        
        // all
        let text: String
        let url: URL?
        let type: ItemType
        let guideID: String
        
        // root categories
        let key: String?
        
        // show
        let subtext: String?
        let genreID: String?
        let item: String?
        let image: String?
        let currentTrack: String?
        let presetID: String?
    }
}
