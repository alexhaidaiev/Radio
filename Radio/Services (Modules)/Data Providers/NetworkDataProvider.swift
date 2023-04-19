//
//  NetworkDataProvider.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 17.04.2023.
//

protocol WebErrorWithGeneralCase where Self: Error {
    static func generalNetwork(_ error: RESTWebError) -> Self
}

protocol NetworkDataProvider: DataProvider {
    associatedtype NRepository: WebRepository
    associatedtype NetworkDataProviderError: DataProviderError, WebErrorWithGeneralCase
    
    var networkRepository: NRepository { get }
    static func map(webError: NRepository.RepositoryError) -> NetworkDataProviderError
}

// MARK: mapping helpers for `RESTWebRepository`

extension NetworkDataProvider where NRepository == RESTWebRepository {
    static func mapBackend(from webError: NRepository.RepositoryError,
                           usingMapping: (RESTWebError.BackendError) -> NetworkDataProviderError?)
    -> NetworkDataProviderError {
        if let backend = webError.asBackend {
            return usingMapping(backend) ?? .generalNetwork(webError)
        }
        return .generalNetwork(webError)
    }
}
