//
//  InMemoryRepository.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 19.04.2023.
//

import Foundation
import UIKit.UIImage

protocol InMemoryCacheRepository: SyncStorageRepository {
    associatedtype ItemType: AnyObject
    
    subscript(webURL: URL) -> ItemType? { get nonmutating set }
    func clearCache()
}

protocol InMemoryCacheRepositoryPrivateAccess {
    func getPrivateCacheItems() -> NSCache<NSURL, AnyObject>
}
// some experiments with private access
//protocol InMemoryCacheRepositoryWithPrivateAccess: InMemoryCacheRepository,
//                                                   InMemoryCacheRepositoryPrivateAccess {}

extension InMemoryCacheRepository where Self: InMemoryCacheRepositoryPrivateAccess {
    subscript(webURL: URL) -> ItemType? {
        get { getPrivateCacheItems().object(forKey: webURL as NSURL) as? Self.ItemType }
        nonmutating set {
            let key = webURL as NSURL
            if let newValue {
                getPrivateCacheItems().setObject(newValue, forKey: key)
            } else {
                getPrivateCacheItems().removeObject(forKey: key)
            }
        }
    }
    
    func clearCache() {
        getPrivateCacheItems().removeAllObjects()
    }
}

// MARK: - Concrete types

struct InMemoryImagesRepository: InMemoryCacheRepository {
    typealias ItemType = UIImage
    
    fileprivate let cacheItems = NSCache<NSURL, UIImage>()
}



// some experiments with private access, not final
extension InMemoryCacheRepositoryPrivateAccess where Self == InMemoryImagesRepository {
    func getPrivateCacheItems() -> NSCache<NSURL, AnyObject> {
        return self.cacheItems as! NSCache<NSURL, AnyObject>
    }
}
// TODO - this line breaks everything, try to avoid it
extension InMemoryImagesRepository: InMemoryCacheRepositoryPrivateAccess {}
