//
//  DownloadedImagesRepository.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 05.05.2023.
//

import Foundation
import UIKit.UIImage

// rename to DownloadsRepository ??
protocol DownloadedFilesRepository {
    associatedtype FileType

    subscript(fileURL: URL) -> FileType? { get }
}

extension DownloadedFilesRepository {
    var fileManager: FileManager { FileManager.default }
    
    func remove(fileURL: URL) { fileManager.remove(fileURL: fileURL) }
    func removeAllFiles(fromDir: URL) { fileManager.removeAllFiles(fromDir: fromDir) }
}

protocol DownloadedDataFilesRepository: DownloadedFilesRepository {
    var constructor: (Data) -> FileType? { get }
}

extension DownloadedDataFilesRepository {
    subscript(fileURL: URL) -> FileType? {
        get { fileManager.loadData(fileURL).flatMap { constructor($0) }}
    }
}
