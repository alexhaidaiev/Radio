//
//  RequestBuilding.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 16.04.2023.
//

import Foundation
import Combine

protocol URLRequestBuilding {
    static func createRequest(from endpoint: RESTEndpoint, params: URLRequestBuilder.BuildParameters)
    -> AnyPublisher<URLRequest, URLRequestBuilder.BuildingError>
}

struct URLRequestBuilder: URLRequestBuilding {
    enum BuildingError: Error {
        case cantCreateURL(String)
        case cantDecodeBody(String)
    }
    struct BuildParameters {
        let baseURL: String
        let commonQueryParameters: [RESTEndpoint.QueryParameter]
    }
    
    static func createRequest(from endpoint: RESTEndpoint, params: BuildParameters)
    -> AnyPublisher<URLRequest, BuildingError> {
        Result { try createURLRequest(from: endpoint, params: params) }
            .publisher
            .mapError { $0 as! BuildingError }
            .eraseToAnyPublisher()
    }
    
    static private func createURLRequest(from endpoint: RESTEndpoint,
                                  params: BuildParameters) throws -> URLRequest {
        var urlComponents = URLComponents()
        let queryItems = endpoint.combinedQueryParamWith(common: params.commonQueryParameters)
        urlComponents.queryItems = queryItems
        urlComponents.path = endpoint.path
        
        guard let baseURL = URL(string: params.baseURL) else {
            let description = "Can't create a URL from baseURL: \(params.baseURL)"
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
