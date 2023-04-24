//
//  SearchDataItems+Fakes.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 23.04.2023.
//

import Foundation

extension Model.SearchDataAudioItem {
    static func fakeStation(index: Int) -> Self {
        .init(id: UUID(),
              text: "fakeStation audio item #\(index)",
              url: URL(string: "http://opml.radiotime.com/Tune.ashx?id=s136649"),
              type: .audio,
              guideID: "s136649",
              subtext: "Some sub text",
              item: "station",
              image: "http://cdn-profiles.tunein.com/s104870/images/logoq.png?t=636403",
              currentTrack: "Some track",
              nowPlayingID: "s136649",
              genreID: "g59",
              formats: "mp3",
              playing: nil,
              playingImage: nil,
              showID: nil,
              presetID: nil,
              streamType: "p525309",
              topicDuration: "s136649")
    }
    
    static func fakeTopic(index: Int) -> Self {
        .init(id: UUID(),
              text: "fakeTopic audio item #\(index)",
              url: URL(string: "http://opml.radiotime.com/Tune.ashx?id=t174472317&sid=p67936&filter=p:topic"),
              type: .audio,
              guideID: "t174472317",
              subtext: "Some sub text",
              item: "topic",
              image: "http://cdn-profiles.tunein.com/p67936/images/logoq.jpg?t=493",
              currentTrack: "Some track",
              nowPlayingID: "t174472317",
              genreID: "g59",
              formats: "mp3",
              playing: nil,
              playingImage: nil,
              showID: nil,
              presetID: nil,
              streamType: "download",
              topicDuration: "3905")
    }
    
    // etc ...
}

extension Model.SearchDataLinkItem {
    static func fakeSportCategory(index: Int) -> Self {
        .init(text: "fakeSportCategory link item #\(index)",
              url: URL(string: "http://opml.radiotime.com/Browse.ashx?id=c100002482"),
              type: .link,
              guideID: "c100002482",
              key: nil,
              subtext: nil,
              genreID: nil,
              item: nil,
              image: nil,
              currentTrack: nil,
              presetID: nil)
    }
}
