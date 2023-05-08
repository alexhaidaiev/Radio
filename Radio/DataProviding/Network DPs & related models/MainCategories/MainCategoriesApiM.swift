//
//  MainCategoriesApiModel.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 08.05.2023.
//

import Foundation

extension APIModel {
    struct MainCategories: APIResponse {
        let head: Head
        let body: [MainCategory]
    }
    
    struct MainCategory: Codable {
        let type: String
        let text: String
        let URL: String
        let key: String
    }
}
