//
//  GraphQLWebRepository.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 16.04.2023.
//

import Combine

enum GraphQlWebError: WebError {
    case noInternet
    case notImplementedYet // remove later
}

struct GraphQLWebRepository: WebRepository {
    // ... some specific properties for GraphQL
    
    func executeRequest<T: Decodable>(endpoint: RESTEndpoint) -> AnyPublisher<T, GraphQlWebError> {
        assertionFailure("Not implemented yet")
        return Fail<T, GraphQlWebError>(error: .notImplementedYet)
            .eraseToAnyPublisher()
    }
}
