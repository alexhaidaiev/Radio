//
//  MainCategoriesDataProvider.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 16.04.2023.
//

import Foundation
import Combine

enum MainCategoriesDPNetworkError: DataProviderError, ErrorWithGeneralRESTWebErrorCase {
    case generalRESTError(_ error: RESTWebError)
    case serviceTemporarilyUnavailable // as an example
}

protocol MainCategoriesDataProviding: NetworkDataProvider, StorageDataProvider
where NetworkDataProviderError == MainCategoriesDPNetworkError {
    func getCategoriesFromAPI() -> AnyPublisher<Model.MainCategories, NetworkDataProviderError>
    func getCategoriesFromStorage() -> AnyPublisher<Model.MainCategories, StorageDataProviderError>
}

struct RealMainCategoriesDataProvider: MainCategoriesDataProviding {
    let networkRepository: RESTWebRepository
    let storageRepository: LocalJSONRepository
    
    func getCategoriesFromAPI()
    -> AnyPublisher<Model.MainCategories, MainCategoriesDPNetworkError> {
        networkRepository
            .executeRequest(for: MainCategoriesEndPoint.mainData)
            .map { Self.mapToMainCategories(apiModel: $0) }
            .mapError { Self.map(webError: $0) }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    // As an example, if we would like to use cache data, etc
    func getCategoriesFromStorage()
    -> AnyPublisher<Model.MainCategories, LocalJSONRepository.RepositoryError> {
        storageRepository
            .getFakeData(from: JSONFiles.Fake.Root.MainCategories)
            .mapError { Self.map(storageError: $0) }
            .eraseToAnyPublisher()
    }
}

// MARK: - Mapping

extension MainCategoriesDataProviding
where NRepository == RESTWebRepository, NRepository.RepositoryError == RESTWebError {
    static func map(webError: RESTWebRepository.RepositoryError) -> MainCategoriesDPNetworkError {
        return mapBackend(from: webError) { backend in
            switch backend.code {
            case 429 where backend.reason == "Overloaded": return .serviceTemporarilyUnavailable
            default: return nil
            }
        }
    }
    
    static func mapToMainCategories(apiModel: APIModel.MainCategories) -> Model.MainCategories {
        .init(title: apiModel.head.title ?? "",
              categories: apiModel.body.map { mapToMainCategory(apiModel: $0) })
    }
    
    static func mapToMainCategory(apiModel: APIModel.MainCategory) -> Model.MainCategory {
        .init(type: apiModel.type,
              text: apiModel.text,
              url: URL(string: apiModel.URL),
              key: .init(rawValue: apiModel.key) ?? .unknown)
    }
}

#if DEBUG
struct FakeMainCategoriesDataProvider: MainCategoriesDataProviding, FakeRepositoryWithJSONsLoading {
    let networkRepository: RESTWebRepository = .fake // TODO: replace to FakeRESTWebRepository()
    let storageRepository: LocalJSONRepository = .fake // TODO: replace to FakeLocalJSONRepository()
    
    func getCategoriesFromAPI()
    -> AnyPublisher<Model.MainCategories, MainCategoriesDPNetworkError> {
        getCategoriesFromStorage()
            .mapError { Self.map(jsonLoadingError: $0) }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func getCategoriesFromStorage()
    -> AnyPublisher<Model.MainCategories, LocalJSONRepository.RepositoryError> {
        storageRepository
            .getFakeData(from: JSONFiles.Fake.Root.MainCategories)
            .fakeAPIDelay
            .map { Self.mapToMainCategories(apiModel: $0) }
            .mapError { Self.map(storageError: $0) }
            .eraseToAnyPublisher()
    }
}
#endif
