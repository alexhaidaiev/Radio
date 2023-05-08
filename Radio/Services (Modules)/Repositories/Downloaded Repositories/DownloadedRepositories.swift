//
//  DownloadedRepositories.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 07.05.2023.
//

import Foundation
import UIKit.UIImage

struct DownloadedMediaRepository: DownloadedFilesRepository, SyncStorageRepository {
    typealias FileType = URL
    
    subscript(fileURL: URL) -> URL? {
        fileManager.isAFileAndExist(at: fileURL) ? fileURL : nil
    }
}

struct DownloadedImagesRepository: DownloadedDataFilesRepository, SyncStorageRepository {
    typealias FileType = UIImage
    
    var constructor: (Data) -> UIImage? = UIImage.init(data:)
}
