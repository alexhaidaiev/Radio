//
//  SearchDataModel.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 08.05.2023.
//

import Foundation

extension Model {
    struct SearchData: Encodable, Equatable {
        struct Section: Identifiable, Equatable {
            static func == (lhs: Model.SearchData.Section, rhs: Model.SearchData.Section) -> Bool {
                lhs.id == rhs.id
            }
            
            private(set) var id = ModelID()
            
            let text: String
            let key: String?
            let items: [any ModelSearchDataItem]
        }
        
        let title: String
        
        // Only one of these fields should be at the same time
        let listOfAudioItems: [SearchDataAudioItem]
        let listOfLinkItems: [SearchDataLinkItem]
        let sectionsWithLists: [Section]
    }
}

// MARK: Support

extension Model.SearchData.Section: Encodable {
    enum CodingKeys: CodingKey {
        case text, key, items
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(text, forKey: .text)
        try container.encode(key, forKey: .key)
        
        var itemsContainer = container.nestedUnkeyedContainer(forKey: .items)
        for item in items {
            try itemsContainer.encode(item)
        }
    }
}
