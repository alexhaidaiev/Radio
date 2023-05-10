//
//  DataProviders & support.swift
//  FindWay
//
//  Created by Oleksandr Haidaiev on 31.03.2023.
//

import Foundation
import Combine

protocol DataProvider {
    typealias AnyCombinePublisher = AnyPublisher
    associatedtype DataProviderError: ErrorWithGeneralAPIError
    
    static func dataProviderErrorFrom(code: Int, reason: String) -> DataProviderError?
}

protocol NetworkDataProvider {
    associatedtype R: WebRepository
    var repository: R { get }
}

// MARK: - Support

protocol ErrorWithGeneralAPIError where Self: Error {
    static func general(api: APIError) -> Self
}

extension DataProvider {
    static func mapErrors(_ apiError: APIError) -> DataProviderError {
        if let someBackend = apiError.asConcreteBackend {
            return dataProviderErrorFrom(code: someBackend.code,
                             reason: someBackend.reason) ?? .general(api: apiError)
        }
        return .general(api: apiError)
    }
}
