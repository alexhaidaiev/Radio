//
//  RequestBuilding.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 16.04.2023.
//

import Foundation
import Combine

protocol URLRequestBuilding {
    func createRequest(from endpoint: RESTEndpoint)
    -> AnyPublisher<URLRequest, URLRequestBuilder.BuildingError>
}

struct URLRequestBuilder: URLRequestBuilding {
    enum BuildingError: Error {
        case cantCreateURL(String)
        case cantDecodeBody(String)
    }
    
    let baseURL: String
    
    func createRequest(from endpoint: RESTEndpoint)
    -> AnyPublisher<URLRequest, BuildingError> {
        Result { try createURLRequest(from: endpoint) }
            .publisher
            .mapError { $0 as! BuildingError }
            .eraseToAnyPublisher()
    }
    
    private func createURLRequest(from endpoint: RESTEndpoint) throws -> URLRequest {
        var urlComponents = URLComponents()
        urlComponents.queryItems = endpoint.queryParameters
        urlComponents.path = endpoint.path
        
        guard let baseURL = URL(string: baseURL) else {
            let description = "Can't create a URL from baseURL: \(baseURL)"
            assertionFailure(description)
            throw BuildingError.cantCreateURL(description)
        }
        guard let url = urlComponents.url(relativeTo: baseURL) else {
            let description = "Can't create a URL from urlComponents: \(urlComponents)"
            assertionFailure(description)
            throw BuildingError.cantCreateURL(description)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.httpMethod.rawValue
        urlRequest.setHeaderValue(endpoint.acceptType.rawValue, for: .acceptMIME)
        
        do {
            if let body = try endpoint.body() {
                urlRequest.httpBody = body
                urlRequest.setHeaderValue(String(body.count), for: .contentLength)
                urlRequest.setHeaderValue(endpoint.contentType.rawValue, for: .contentType)
            }
        } catch let error {
            let description = "Can't decode body: \(error.localizedDescription)"
            assertionFailure(description)
            throw BuildingError.cantDecodeBody(description)
        }
        return urlRequest
    }
}

fileprivate extension URLRequest {
    mutating func setHeaderValue(_ value: String?, for field: HTTPHeaderField) {
        self.setValue(value, forHTTPHeaderField: field.rawValue)
    }
}
