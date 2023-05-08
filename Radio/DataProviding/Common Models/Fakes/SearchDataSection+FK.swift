//
//  SearchDataSection+Fake.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 24.04.2023.
//

import Foundation

extension Model.SearchData.Section {
    static var fakeSectionWithRadioAudioItems: Self {
        .init(text: "Fake section with stations",
              key: nil,
              items: [
                Model.SearchDataAudioItem.fakeStation(index: 1),
                Model.SearchDataAudioItem.fakeStation(index: 2),
                Model.SearchDataAudioItem.fakeStation(index: 3),
                Model.SearchDataAudioItem.fakeStation(index: 4)
              ]
        )
    }
    static var fakeSectionWithSportLinkItems: Self {
        .init(text: "Fake section with sport links",
              key: nil,
              items: [
                Model.SearchDataLinkItem.fakeSportCategory(index: 1),
                Model.SearchDataLinkItem.fakeSportCategory(index: 2),
                Model.SearchDataLinkItem.fakeSportCategory(index: 3),
                Model.SearchDataLinkItem.fakeSportCategory(index: 4)
              ]
        )
    }
}
