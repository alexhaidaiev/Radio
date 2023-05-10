//
//  ConnectionDetailsDataProvider.swift
//  FindWay
//
//  Created by Oleksandr Haidaiev on 01.04.2023.
//

import Foundation
import Combine

enum ConnectionDetailsDataProviderError: ErrorWithGeneralAPIError {
    case general(api: APIError)
    case doesntExist
    // ... other specific errors
}

protocol ConnectionDetailsDataProvider: DataProvider
where DataProviderError == ConnectionDetailsDataProviderError {
    func getConnectionDetails(id: UUID) -> AnyPublisher<Trip, DataProviderError>
}

extension ConnectionDetailsDataProvider {
    static func dataProviderErrorFrom(code: Int, reason: String) -> DataProviderError? {
        switch code {
        case 404 where reason == "Unknown id": return .doesntExist
        default: return nil
        }
    }
}

// TODO: write some example
