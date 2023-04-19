//
//  StorageDataProvider.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 17.04.2023.
//

protocol StorageDataProvider: DataProvider {
    associatedtype SRepository: StorageRepository
    associatedtype StorageDataProviderError: DataProviderError
    
    var storageRepository: SRepository { get }
    static func map(storageError: SRepository.GetError) -> StorageDataProviderError
}

// MARK: mapping helpers for `LocalJSONRepository`

// Since `LocalJSONRepository.RepositoryError`s are the same for all `LocalJSONRepository`s,
// we can use them as `StorageDataProviderError`, so DPs can use them directly without
// mapping from `GetError` to `StorageDataProviderError`
typealias LocalJSONDPError = LocalJSONRepository.RepositoryError
extension LocalJSONDPError: DataProviderError { }

extension StorageDataProvider
where SRepository == LocalJSONRepository,
      StorageDataProviderError == LocalJSONRepository.RepositoryError {
    static func map(storageError: LocalJSONRepository.RepositoryError) -> LocalJSONDPError {
        storageError
    }
}
