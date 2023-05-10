//
//  RequestBuilder.swift
//  FindWay
//
//  Created by Oleksandr Haidaiev on 26.03.2023.
//

import Foundation
import Combine

enum RequestBuildingError: ErrorWithUnwrapError {
    case urlRequestIsEmpty
}

protocol RequestBuilding {
    func createRequest(from endpoint: Endpoint) -> AnyPublisher<URLRequest, RequestBuildingError>
}

struct RequestBuilder: RequestBuilding {
#if DEBUG
    var baseURL: String // e.g to change environments from a debug menu during testing
#else
    let baseURL: String
#endif
    
    func createRequest(from endpoint: Endpoint) -> AnyPublisher<URLRequest, RequestBuildingError> {
        let urlRequest = createURLRequest(from: endpoint)
        return CurrentValueSubject<URLRequest?, RequestBuildingError>(urlRequest)
            .unwrap(orThrow: .urlRequestIsEmpty)
            .eraseToAnyPublisher()
    }
    
    private func createURLRequest(from endpoint: Endpoint) -> URLRequest? {
        var urlComponents = URLComponents()
        urlComponents.queryItems = endpoint.parameters
        urlComponents.path = endpoint.path
        
        guard let url = urlComponents.url(relativeTo: URL(string: baseURL)) else {
            assertionFailure("Can't create a URL from: \(baseURL) and: \(urlComponents)")
            return nil
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.method.rawValue
        urlRequest.setHeaderValue(endpoint.acceptType.rawValue, for: .acceptMIME)
        
        do {
            if let body = try endpoint.body() {
                urlRequest.httpBody = body
                urlRequest.setHeaderValue(String(body.count), for: .contentLength)
                urlRequest.setHeaderValue(endpoint.contentType.rawValue, for: .contentType)
            }
        } catch let error {
            assertionFailure("Can't add httpBody: \(error.localizedDescription)")
            return nil
        }
        return urlRequest
    }
}

fileprivate extension URLRequest {
    mutating func setHeaderValue(_ value: String?, for field: HTTPHeaderField) {
        self.setValue(value, forHTTPHeaderField: field.rawValue)
    }
}
