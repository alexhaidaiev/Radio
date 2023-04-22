//
//  DataProvidersFactory.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 22.04.2023.
//

struct DataProvidersFactory {
    let appState: Store<AppState>
    
    func createMainCategoriesDP() -> any MainCategoriesDataProviding {
        return RealMainCategoriesDataProvider(networkRepository: createCommonRESTWebRepository(),
                                              storageRepository: LocalJSONRepository())
    }
    
    func createSearchDP() -> any SearchDataProviding {
        return RealSearchDataProvider(networkRepository: createCommonRESTWebRepository())
    }
    
    private func createCommonRESTWebRepository() -> RESTWebRepository {
        let network = appState[\.network]
        let requestBuilderParams = URLRequestBuilder.BuildParameters(
            baseURL: appState[\.environment].baseURL,
            commonQueryParameters: network.commonQueryParameters)
        return RESTWebRepository(session: network.urlSession,
                                 requestBuilderParams: requestBuilderParams,
                                 requestBuilderType: URLRequestBuilder.self)
    }
}
