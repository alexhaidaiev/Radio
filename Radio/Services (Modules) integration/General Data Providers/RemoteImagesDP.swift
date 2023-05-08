//
//  RemoteImagesDataProvider.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 07.05.2023.
//

import Foundation
import UIKit.UIImage
import Combine

protocol RemoteImagesDataProviding: DownloadDataProviderWithInMemoryCacheRepository {
    func getSmallImage(url webURL: URL,
                       isSaveInCache: Bool) -> AnyPublisher<UIImage?, Never>
    func getImage(url webURL: URL,
                  isForceLoad: Bool,
                  isSaveInCache: Bool,
                  isSaveOnDisc: Bool) -> AnyPublisher<UIImage?, DownloadWebError>
}

struct RemoteImagesDataProvider: RemoteImagesDataProviding {
    let downloadRepository: DownloadRepository
    let downloadedFilesRepository = DownloadedImagesRepository()
    let inMemoryCacheRepository = InMemoryImagesRepository()
    
    let temporalDirectory: URL
    let permanentDirectory: URL
    
    func getSmallImage(url webURL: URL,
                       isSaveInCache: Bool = true) -> AnyPublisher<UIImage?, Never> {
        return downloadRepository
            .downloadToMemory(url: webURL)
            .compactMap { $0 }
            .compactMap { UIImage(data: $0) }
            .handleEvents(receiveOutput: { inMemoryCacheRepository[webURL] = $0 })
            .eraseToAnyPublisher()
    }
    
    func getImage(url webURL: URL,
                  isForceLoad: Bool = false,
                  isSaveInCache: Bool = true,
                  isSaveOnDisc: Bool = false) -> AnyPublisher<UIImage?, DownloadWebError> {
        let permanentImageLocation = permanentDirectory + uniquePathOfImageOnDisc(from: webURL)
        let temporalImageLocation = temporalDirectory + uniquePathOfImageOnDisc(from: webURL)
        
        if !isForceLoad {
            let cachedImage = inMemoryCacheRepository[webURL]
            ?? downloadedFilesRepository[permanentImageLocation]
            ?? downloadedFilesRepository[temporalImageLocation]
            
            if let cachedImage {
                return Just(cachedImage)
                    .setFailureType(to: DownloadWebError.self)
                    .eraseToAnyPublisher()
            }
        }
        
        let targetDir = isSaveOnDisc ? permanentImageLocation : temporalImageLocation
        return downloadRepository
            .downloadToDisk(url: webURL, to: targetDir)
            .tryMap {
                do {
                    let uiImage = UIImage(data: try Data(contentsOf: $0))
                    if isSaveInCache {
                        inMemoryCacheRepository[webURL.absoluteURL] = uiImage
                    }
                    return uiImage
                } catch {
                    assertionFailure("Can't load data for path: \(targetDir), error: \(error)")
                    throw DownloadWebError.storageError(error)
                }
            }
            .mapError { Self.map(downloadError: $0 as! DownloadWebError) }
            .eraseToAnyPublisher()
    }
}
