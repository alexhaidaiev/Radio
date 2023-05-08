//
//  GraphQLWebRepository.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 16.04.2023.
//

import Combine

enum GraphQlWebError: WebError {
    case noInternet
    case responseTimeOut
    case notImplementedYet // remove later
}

struct GraphGLQuery {
    // ...
}

struct GraphQLWebRepository: WebRepository {
    typealias RepositoryError = GraphQlWebError
    
    // ... some specific properties for GraphQL
    
    func executeRequest<T>(for: GraphGLQuery) -> AnyPublisher<T, GraphQlWebError> {
        assertionFailure("Not implemented yet")
        return Fail<T, GraphQlWebError>(error: .notImplementedYet)
            .eraseToAnyPublisher()
    }
}
