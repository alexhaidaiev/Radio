//
//  DataProvidersFactory.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 22.04.2023.
//

import Foundation.NSURLSession

protocol ADataProvidersFactory {
    func createMainCategoriesDP() -> any MainCategoriesDataProviding
    func createSearchDP() -> any SearchDataProviding
    func createOfflineMediaFilesDP() -> any OfflineMediaFilesDataProviding
    func createRemoteImagesDP() -> any RemoteImagesDataProviding
}

struct DataProvidersFactory: ADataProvidersFactory {
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
    
    // MARK: - Common reusable Data Providers
    
    func createOfflineMediaFilesDP() -> any OfflineMediaFilesDataProviding {
        let bgSession = appState[\.network].backgroundURLSession
        let repository = createDownloadRepository(bgSession)
        let directory = DownloadManager.permanentDirForMedia
        return OfflineMediaFilesDataProvider(downloadRepository: repository,
                                             permanentDirectory: directory)
    }
    
    func createRemoteImagesDP() -> any RemoteImagesDataProviding {
        return RemoteImagesDataProvider(downloadRepository: createDownloadRepository(),
                                        temporalDirectory: DownloadManager.temporalDirForImages,
                                        permanentDirectory: DownloadManager.permanentDirForImages)
    }
    
    // MARK: - Private
    
    private func createRESTWebRepository() -> RESTWebRepository {
        let network = appState[\.network]
        let requestBuilderParams = URLRequestBuilder.BuildParameters(
            baseURL: appState[\.environment].baseURL,
            commonQueryParameters: network.commonQueryParameters)
        return RESTWebRepository(session: network.urlSession,
                                 requestBuilderParams: requestBuilderParams,
                                 requestBuilderType: URLRequestBuilder.self,
                                 jsonDecoder: .standard)
    }
    
    private func createDownloadRepository(_ specificSession: URLSession? = nil) -> DownloadRepository {
        return DownloadRepository(session: specificSession ?? appState[\.network].urlSession)
    }
}
