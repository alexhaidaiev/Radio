//
//  MainCategoriesDataProvider.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 16.04.2023.
//

import Foundation
import Combine

enum MainCategoriesNetworkDPError: DataProviderError, WebErrorWithGeneralCase {
    case generalNetwork(_ error: RESTWebError)
    case serviceTemporarilyUnavailable // as an example
}

protocol MainCategoriesDataProviding: NetworkDataProvider, StorageDataProvider
where NetworkDataProviderError == MainCategoriesNetworkDPError {
    func getDataFromAPI() -> AnyPublisher<MainCategoriesModel, NetworkDataProviderError>
    func getDataFromStorage() -> AnyPublisher<MainCategoriesModel, StorageDataProviderError>
}

struct RealMainCategoriesDataProvider: MainCategoriesDataProviding {
    typealias StorageDataProviderError = LocalJSONRepository.RepositoryError
    
    let networkRepository: RESTWebRepository
    let storageRepository: LocalJSONRepository
    
    func getDataFromAPI() -> AnyPublisher<MainCategoriesModel, MainCategoriesNetworkDPError> {
        networkRepository
            .executeRequest(endpoint: MainCategoriesEndPoint.mainData)
            .map { Self.mapToMainCategories(apiModel: $0) }
            .mapError { Self.map(webError: $0) }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func getDataFromStorage() -> AnyPublisher<MainCategoriesModel,
                                              LocalJSONRepository.RepositoryError> {
        storageRepository
            .getFakeData(from: JSONFiles.FakeMainCategories.default)
            .mapError { Self.map(storageError: $0) }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Mapping
    
    static func mapToMainCategories(apiModel: APIModel.MainCategories) -> MainCategoriesModel {
        .init(title: apiModel.head.title,
              sources: apiModel.body.map { MainCategoryModel(from: $0) })
    }
    
    static func map(webError: RESTWebRepository.RepositoryError) -> MainCategoriesNetworkDPError {
        return mapBackend(from: webError) { backend in
            switch backend.code {
            case 429 where backend.reason == "Overloaded": return .serviceTemporarilyUnavailable
            default: return nil
            }
        }
    }
}

fileprivate extension MainCategoryModel {
    init(from apiModel: APIModel.MainCategory) {
        type = apiModel.type
        text = apiModel.text
        url = apiModel.url
        key = .init(rawValue: apiModel.key) ?? .unknown
    }
}
