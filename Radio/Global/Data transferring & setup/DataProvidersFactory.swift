//
//  DataProvidersFactory.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 22.04.2023.
//

protocol DataProvidersFactoryP {
    func createMainCategoriesDP() -> any MainCategoriesDataProviding
    func createSearchDP() -> any SearchDataProviding
}

struct DataProvidersFactory: DataProvidersFactoryP {
    let appState: Store<AppState>
    
    func createMainCategoriesDP() -> any MainCategoriesDataProviding {
        if appState[\.debugFeatures].isOfflineMode {
            return FakeMainCategoriesDataProvider()
        } else {
            return RealMainCategoriesDataProvider(networkRepository: createRESTWebRepository(),
                                                  storageRepository: LocalJSONRepository())
        }
    }
    
    func createSearchDP() -> any SearchDataProviding {
        if appState[\.debugFeatures].isOfflineMode {
            return FakeSearchDataProvider()
        } else {
            return RealSearchDataProvider(networkRepository: createRESTWebRepository())
        }
    }
    
    // MARK: - Private
    
    private func createRESTWebRepository() -> RESTWebRepository {
        let network = appState[\.network]
        let requestBuilderParams = URLRequestBuilder.BuildParameters(
            baseURL: appState[\.environment].baseURL,
            commonQueryParameters: network.commonQueryParameters)
        return RESTWebRepository(session: network.urlSession,
                                 requestBuilderParams: requestBuilderParams,
                                 requestBuilderType: URLRequestBuilder.self)
    }
}
