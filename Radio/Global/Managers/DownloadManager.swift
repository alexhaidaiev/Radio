//
//  DownloadManager.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 08.05.2023.
//

import Foundation

class DownloadManager {
    static let permanentDirForMedia = FileManager
        .directory(for: .documentDirectory)
        .appending(path: "audio_files/offline")
    
    static let permanentDirForImages = FileManager
        .directory(for: .documentDirectory)
        .appending(path: "images/remote")
    
    static let temporalDirForImages = FileManager
        .directory(for: .cachesDirectory)
        .appending(path: "images")
}

class CacheManager {
    // add functionality
}
