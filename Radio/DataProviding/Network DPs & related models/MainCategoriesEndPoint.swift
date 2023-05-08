//
//  MainCategoriesEndPoint.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 18.04.2023.
//

extension RealMainCategoriesDataProvider {
    enum MainCategoriesEndPoint: RESTEndpoint {
        case mainData
        
        var responseType: APIResponse.Type {
            switch self {
            case .mainData: return APIModel.MainCategories.self
            }
        }
        
        var path: String {
            switch self {
            case .mainData: return "" // same as base URL
            }
        }
    }
}

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
