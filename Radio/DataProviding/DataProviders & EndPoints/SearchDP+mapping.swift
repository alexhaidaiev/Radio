//
//  SearchDataProvider+mapping.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 22.04.2023.
//

import Foundation

protocol APIEntityWithSearchItem {
    var getType: String { get }
    
    var text: String { get }
    var URL: String? { get }
    var guideId: String? { get }
    //    var bitrate: String? { get }
    //    var reliability: String? { get }
    var subtext: String? { get }
    var genreId: String? { get }
    var formats: String? { get }
    var playing: String? { get }
    var playingImage: String? { get }
    var showId: String? { get }
    var item: String? { get }
    var image: String? { get }
    var currentTrack: String? { get }
    var nowPlayingId: String? { get }
    var presetId: String? { get }
    var streamType: String? { get }
    var topicDuration: String? { get }
}

extension APIModel.SearchContent: APIEntityWithSearchItem {
    var getType: String { type ?? "" }
}
extension APIModel.SearchItem: APIEntityWithSearchItem {
    var getType: String { type }
}

extension RealSearchDataProvider {
    static func mapToSearchItems(_ content: APIModel.SearchContent) -> [any ModelSearchDataItem] {
        guard let children = content.children else { return [] }
        
        let items = children.compactMap { item -> (any ModelSearchDataItem)? in
            if item.type == Model.SearchDataItemType.audio.rawValue {
                return mapToAudioItem(item)
            } else if item.type == Model.SearchDataItemType.link.rawValue {
                return mapToLinkItem(item, key: content.key)
            }
            return nil
        }
        return items
    }
    
    static func mapToAudioItem(_ entity: APIEntityWithSearchItem) -> Model.SearchDataAudioItem {
        .init(text: entity.text,
              url: URL(string: entity.URL ?? ""),
              type: .init(rawValue: entity.getType) ?? .unknown,
              guideID: entity.guideId ?? "",
              subtext: entity.subtext,
              item: entity.item,
              image: entity.image,
              currentTrack: entity.currentTrack,
              nowPlayingID: entity.nowPlayingId,
//              bitrate: content.bitrate,
//              reliability: content.reliability,
              genreID: entity.genreId,
              formats: entity.formats,
              playing: entity.playing,
              playingImage: entity.playingImage,
              showID: entity.showId,
              presetID: entity.presetId,
              streamType: entity.streamType,
              topicDuration: entity.topicDuration)
    }
    
    static func mapToLinkItem(_ entity: APIEntityWithSearchItem,
                              key: String?) -> Model.SearchDataLinkItem {
        .init(text: entity.text,
              url: URL(string: entity.URL ?? ""),
              type: .init(rawValue: entity.getType) ?? .unknown,
              guideID: entity.guideId ?? "",
              key: key,
              subtext: entity.subtext,
              genreID: entity.genreId,
              item: entity.item,
              image: entity.image,
              currentTrack: entity.currentTrack,
              presetID: entity.presetId)
    }
}
