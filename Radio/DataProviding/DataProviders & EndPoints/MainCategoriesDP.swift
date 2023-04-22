//
//  MainCategoriesDataProvider.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 16.04.2023.
//

import Foundation
import Combine

enum MainCategoriesDPNetworkError: DataProviderError, WebErrorWithGeneralCase {
    case generalNetwork(_ error: RESTWebError)
    case serviceTemporarilyUnavailable // as an example
}

protocol MainCategoriesDataProviding: NetworkDataProvider, StorageDataProvider
where NetworkDataProviderError == MainCategoriesDPNetworkError {
    func getDataFromAPI() -> AnyPublisher<Model.MainCategories, NetworkDataProviderError>
    func getDataFromStorage() -> AnyPublisher<Model.MainCategories, StorageDataProviderError>
}

struct RealMainCategoriesDataProvider: MainCategoriesDataProviding {
    typealias StorageDataProviderError = LocalJSONRepository.RepositoryError
    
    let networkRepository: RESTWebRepository
    let storageRepository: LocalJSONRepository
    
    func getDataFromAPI() -> AnyPublisher<Model.MainCategories, MainCategoriesDPNetworkError> {
        networkRepository
            .executeRequest(endpoint: MainCategoriesEndPoint.mainData)
            .map { Self.mapToMainCategories(apiModel: $0) }
            .mapError { Self.map(webError: $0) }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func getDataFromStorage() -> AnyPublisher<Model.MainCategories,
                                              LocalJSONRepository.RepositoryError> {
        storageRepository
            .getFakeData(from: JSONFiles.FakeMainCategories.default)
            .mapError { Self.map(storageError: $0) }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Mapping
    
    static func map(webError: RESTWebRepository.RepositoryError) -> MainCategoriesDPNetworkError {
        return mapBackend(from: webError) { backend in
            switch backend.code {
            case 429 where backend.reason == "Overloaded": return .serviceTemporarilyUnavailable
            default: return nil
            }
        }
    }
    
    static func mapToMainCategories(apiModel: APIModel.MainCategories) -> Model.MainCategories {
        .init(title: apiModel.head.title,
              categories: apiModel.body.map { mapToMainCategory(apiModel: $0) })
    }
    
    static func mapToMainCategory(apiModel: APIModel.MainCategory) -> Model.MainCategory {
        .init(type: apiModel.type,
              text: apiModel.text,
              url: URL(string: apiModel.URL),
              key: .init(rawValue: apiModel.key) ?? .unknown)
    }
}
