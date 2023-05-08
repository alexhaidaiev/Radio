//
//  FileManager+extensions.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 30.04.2023.
//

import Foundation

extension FileManager {
    static func directory(for directoryType: SearchPathDirectory) -> URL {
        Self.default.urls(for: directoryType, in: .userDomainMask).first!
    }
    
    func isAFileAndExist(at fileLocation: URL) -> Bool {
        var isDirectory: ObjCBool = false
        guard self.fileExists(atPath: fileLocation.absoluteString, isDirectory: &isDirectory),
              isDirectory.boolValue == false else { return false }
        return true
    }
    
    /// In addition, it creates intermediate directories if needed
    func moveItemSafe(at atURL: URL, to toURL: URL) throws {
        print("currentFilePath ", atURL) // TODO: remove extra logs after testing
        
        let folder = toURL.deletingLastPathComponent()
        print("folder ", folder)
        
        if !self.fileExists(atPath: folder.path) {
            try self.createDirectory(
                at: folder,
                withIntermediateDirectories: true
            )
        }
        let targetPathWithName = toURL.appending(path: atURL.lastPathComponent)
        
        try? self.removeItem(at: targetPathWithName)
        try self.moveItem(atPath: atURL.path, toPath: targetPathWithName.path)
        print("destinationPath ", targetPathWithName)
    }
    
    func loadData(_ path: URL) -> Data? {
        do {
            return try Data(contentsOf: path)
        } catch {
            assertionFailure("Can't load data for path: \(path), error: \(error)")
            return nil
        }
    }
    
    @discardableResult
    func remove(fileURL: URL) -> Bool {
        guard isAFileAndExist(at: fileURL) else { return false }
        
        do {
            try removeItem(at: fileURL)
            return true
        } catch {
            print("Can't remove file by name: \(fileURL), error: \(error)")
            return false
        }
    }
    
    func removeAllFiles(fromDir: URL) {
        do {
            let fileURLs = try contentsOfDirectory(at: fromDir)
            for fileURL in fileURLs {
                do {
                    try removeItem(at: fileURL)
                } catch {
                    print("Can't remove file by URL: \(fileURL), error: \(error)")
                }
            }
        } catch {
            print("Can't get content of directory: \(error)") // TODO: add wrapper/logger
        }
    }
    
    func contentsOfDirectory(at url: URL) throws -> [URL] {
        return try self.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
    }
}
