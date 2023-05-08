//
//  OfflineMediaFilesDataProvider.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 07.05.2023.
//

import Foundation
import Combine

protocol OfflineMediaFilesDataProviding: DownloadDataProviding {
    typealias DownloadState = DownloadRepository.DownloadState
    
    func isFileDownloaded(for webURL: URL) -> Bool
    func downloadFile(for webURL: URL) -> AnyPublisher<DownloadState, DownloadWebError>
}

struct OfflineMediaFilesDataProvider: OfflineMediaFilesDataProviding {
    let downloadRepository: DownloadRepository
    let downloadedFilesRepository = DownloadedMediaRepository()
    
    var permanentDirectory: URL
    
    func isFileDownloaded(for webURL: URL) -> Bool {
        downloadedFilesRepository[expectedLocation(for: webURL)] != nil
    }
    
    func downloadFile(for webURL: URL) -> AnyPublisher<DownloadState, DownloadWebError> {
        let targetLocation = expectedLocation(for: webURL)
        if let fileLocation = downloadedFilesRepository[targetLocation] {
            assertionFailure("Use `isFileDownloaded` to check if a file exist before download it")
            return Just(.finished(targetFileLocation: fileLocation))
                .setFailureType(to: DownloadWebError.self)
                .eraseToAnyPublisher()
        }
        
        return downloadRepository
            .downloadToDiskWithProgress(url: webURL, to: targetLocation)
            .mapError { Self.map(downloadError: $0) }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    private func expectedLocation(for webURL: URL) -> URL {
        permanentDirectory + uniquePathOfImageOnDisc(from: webURL)
    }
}
