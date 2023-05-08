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
