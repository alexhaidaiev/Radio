//
//  NetworkDataProviding.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 17.04.2023.
//

protocol ErrorWithGeneralRESTWebErrorCase where Self: Error {
    static func generalRESTError(_ error: RESTWebError) -> Self
}

protocol NetworkDataProviding: DataProvider {
    associatedtype NRepository: WebRepository
    associatedtype NetworkDataProviderError: DataProviderError, ErrorWithGeneralRESTWebErrorCase
    
    var networkRepository: NRepository { get }
    static func map(webError: NRepository.RepositoryError) -> NetworkDataProviderError
}

// MARK: mapping helpers for `RESTWebRepository`

extension NetworkDataProviding where NRepository == RESTWebRepository {
    static func mapBackend(from webError: NRepository.RepositoryError,
                           usingMapping: (RESTWebError.BackendError) -> NetworkDataProviderError?)
    -> NetworkDataProviderError {
        if let backend = webError.asBackend {
            return usingMapping(backend) ?? .generalRESTError(webError)
        }
        return .generalRESTError(webError)
    }
}
