//
//  DownloadDataProviding.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 30.06.2023.
//

import Foundation
import UIKit.UIImage
import Combine

typealias DownloadDataProviderError = DownloadWebError // we can use this error type directly

protocol DownloadDataProviding: DataProvider {
    associatedtype DownloadedRepository: DownloadedFilesRepository
    
    var downloadRepository: DownloadRepository { get }
    var downloadedFilesRepository: DownloadedRepository { get }
    static func map(downloadError: DownloadRepository.RepositoryError) -> DownloadDataProviderError
}

extension DownloadDataProviding {
    static func map(downloadError: DownloadRepository.RepositoryError) -> DownloadDataProviderError {
        return downloadError
    }

    func uniquePathOfImageOnDisc(from webURL: URL) -> String {
        return webURL.relativePath
    }
}

protocol DownloadDataProviderWithInMemoryCacheRepository: DownloadDataProviding {
    associatedtype InMemoryRepository: InMemoryCacheRepository

    var inMemoryCacheRepository: InMemoryRepository { get }
}
