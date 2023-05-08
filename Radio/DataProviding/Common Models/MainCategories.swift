//
//  MainCategoryModel.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 17.04.2023.
//

import Foundation

extension Model {
    struct MainCategories: Codable, Equatable {
        let title: String
        let categories: [Model.MainCategory]
    }
    
    struct MainCategory: Codable, Identifiable, Equatable {
        enum Key: String, Codable, Equatable {
            case local, music, talk, sports, location, language, podcast
            case unknown
        }
        private(set) var id = ModelID()
        
        let type: String
        let text: String
        let url: URL?
        let key: Key
    }
}
