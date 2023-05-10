//
//  HTTPWebRepository.swift
//  FindWay
//
//  Created by Oleksandr Haidaiev on 25.03.2023.
//

import Foundation
import Combine

protocol WebRepository {}

struct HTTPWebRepository: WebRepository {
    let session: URLSession
    let requestBuilder: RequestBuilding
}

struct GraphQLWebRepository: WebRepository {
    // ... some specific properties for GraphQL
}

// MARK: Common REST logic

extension HTTPWebRepository {
    func performHTTPRequest<ResponseData: Decodable>(_ endpoint: Endpoint)
    -> AnyPublisher<ResponseData, APIError> {
        return requestBuilder.createRequest(from: endpoint)
            .mapError { requestBuildingError in
                switch requestBuildingError {
                case .urlRequestIsEmpty: return APIError.cantCreateRequest
                }
            }
            .flatMap { urlRequest -> AnyPublisher<ResponseData, Error> in
                executeRequest(for: urlRequest)
            }
            .tryCatch { error -> AnyPublisher<ResponseData, Error> in
                if let apiError = error as? APIError, apiError.isGlobal {
                    // handle global errors
                }
                throw error
            }
            .mapError { $0 as? APIError ?? .unknown }
            .eraseToAnyPublisher()
    }
    
    func executeRequest<ResponseData: Decodable>(for urlRequest: URLRequest)
    -> AnyPublisher<ResponseData, Error> {
        session
            .dataTaskPublisher(for: urlRequest)
            .tryMapToHTTPURLResponse()
            .tryFilterByHTTPCodes(.success)
            .tryMapToDataAndMimeType()
            .decodeMIME(type: ResponseData.self)
        
            .tryCatch { error -> AnyPublisher<ResponseData, Error> in
                if case .backend(let type) = error as? APIError,
                   case .concrete(let code, _) = type,
                   code == HTTPCodes.unauthorized {
                    throw APIError.backend(.unauthorised)
                }
                // check other network errors
                throw error
            }
            .eraseToAnyPublisher()
    }
}

fileprivate extension Publisher {
    func tryMapToHTTPURLResponse() -> Publishers.TryMap<Self, (data: Data,
                                                               httpURLResponse: HTTPURLResponse)>
    where Self.Output == URLSession.DataTaskPublisher.Output {
        tryMap { data, response -> (Data, HTTPURLResponse) in
            guard let response = response as? HTTPURLResponse else {
                throw APIError.unexpectedResponse
            }
            
            return (data, response)
        }
    }

    func tryFilterByHTTPCodes(_ codes: HTTPCodes) -> Publishers.TryFilter<Self>
    where Self.Output == (data: Data, httpURLResponse: HTTPURLResponse) {
        tryFilter { (data: Data, httpURLResponse: HTTPURLResponse) in
            guard codes.contains(httpURLResponse.statusCode) else {
                let data: Data? = data.isEmpty ? nil : data
                var reason = "unknown"
                if let data, let string = String(data: data, encoding: .utf8) {
                    reason = string
                }
                throw APIError.backend(.concrete(code: httpURLResponse.statusCode, reason: reason))
            }
            return true
        }
    }
    
    func tryMapToDataAndMimeType() -> Publishers.TryMap<Self, (Data, MIMEType)>
    where Self.Output == (data: Data, httpURLResponse: HTTPURLResponse) {
        tryMap { (data: Data, httpURLResponse: HTTPURLResponse) in
            guard let mimeType = httpURLResponse.mimeType,
                  let mimeType = MIMEType(rawValue: mimeType) else {
                throw APIError.unexpectedResponse
            }
            
            return (data, mimeType)
        }
    }
    
    func decodeMIME<Item>(type: Item.Type) -> Publishers.TryMap<Self, Item>
    where Item: Decodable, Self.Output == (Data, MIMEType) {
        tryMap { data, mimetype in
            let result: Item
            switch mimetype {
            case .json:
                result = try JSONDecoder().decode(type, from: data)
            case .plain:
                // we receive text in the JSON format
                result = try JSONDecoder().decode(type, from: data)
            }
            return result
        }
    }
}
