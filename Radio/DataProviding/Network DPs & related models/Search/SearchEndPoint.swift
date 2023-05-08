//
//  SearchEndPoint.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 19.04.2023.
//

import Foundation

extension RealSearchDataProvider {
    enum SearchEndPoint: RESTEndpoint {
        case byCategory(_ category: String)
        case byId(_ id: String)
        
        var responseType: APIResponse.Type {
            switch self {
            case .byCategory: return APIModel.SearchRoot.self
            case .byId: return APIModel.SearchRoot.self
            }
        }
        
        var path: String { "Browse.ashx" }
        
        var queryParameters: [QueryParameter] {
            switch self {
            case .byCategory(let category):
                return [.init(name: "c", value: category)]
            case .byId(let id):
                return [.init(name: "id", value: id)]
            }
        }
    }
}
