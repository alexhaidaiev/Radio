//
//  MainCategoryModel.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 17.04.2023.
//

import Foundation

struct MainCategoriesModel: Codable {
    let title: String?
    let sources: [MainCategoryModel]
}

struct MainCategoryModel: Codable, Identifiable {
    enum Key: String, Codable {
        case local, music, talk, sports, location, language, podcast
        case unknown
    }
    private(set) var id = UUID()
    
    let type: String
    let text: String
    let url: String
    let key: Key
}
