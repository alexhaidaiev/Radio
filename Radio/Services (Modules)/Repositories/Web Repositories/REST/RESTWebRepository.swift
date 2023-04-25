//
//  RESTWebRepository.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 16.04.2023.
//

import Foundation
import Combine

enum RESTWebError: WebError {
    case noInternet
    case requestCreationFailed(String)
    
    case responseTimeOut
    case responseURLError(URLError)
    case responseUnknownFormat
    case responseUnsupportedMimeType(String?)
    case responseDecodingFailed(Error)
    
    case unauthorized
    case backend(BackendError)
}
extension RESTWebError {
    struct BackendError {
        let code: HTTPStatusCode
        let reason: String
        let faultCode: String?
        
        fileprivate static let unknownReasonPlaceholder = "No reason from the server side"
    }
    
    var asBackend: BackendError? {
        if case let .backend(error) = self { return error }
        return nil
    }
}

struct RESTWebRepository: WebRepository {
    let session: URLSession
    var requestBuilderParams: URLRequestBuilder.BuildParameters
    
    let requestBuilderType: URLRequestBuilding.Type
    var jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return decoder
    }()
    
    func executeRequest<T: APIResponse>(for endpoint: RESTEndpoint)
    -> AnyPublisher<T, RESTWebError> {
        requestBuilderType.createRequest(from: endpoint, params: requestBuilderParams)
            .mapError { requestBuildingError in
                switch requestBuildingError {
                case .cantCreateURL(let desc): return RESTWebError.requestCreationFailed(desc)
                case .cantDecodeBody(let desc): return RESTWebError.requestCreationFailed(desc)
                }
            }
            .flatMap { urlRequest -> AnyPublisher<T, RESTWebError> in
                executeAndHandleURLRequest(urlRequest, responseType: endpoint.responseType.self)
            }
            .eraseToAnyPublisher()
    }
    
    func executeRequest<T: APIResponse>(url: URL) -> AnyPublisher<T, RESTWebError> {
        let urlWithParams = url.appending(queryItems: requestBuilderParams.commonQueryParameters)
        return executeAndHandleURLRequest(URLRequest(url: urlWithParams),
                                          responseType: T.self)
    }
    
    private func executeAndHandleURLRequest<T: APIResponse>(_ urlRequest: URLRequest,
                                                            responseType: APIResponse.Type)
    -> AnyPublisher<T, RESTWebError> {
        session
            .dataTaskPublisher(for: urlRequest)
            .mapError { $0.code == .timedOut ? .responseTimeOut : .responseURLError($0) }
            .tryMapToHTTPURLResponse()
            .tryCheckHTTPSuccessCodes()
            .tryMapToMimeType()
            .tryDecode(to: responseType as! T.Type, jsonDecoder: jsonDecoder)
            .eraseToAnyPublisher()
    }
}

// MARK: Publisher mappers

fileprivate extension Publisher where Failure == RESTWebError {
    func tryMapToHTTPURLResponse() -> AnyPublisher<(Data, HTTPURLResponse), RESTWebError>
    where Self.Output == URLSession.DataTaskPublisher.Output {
        tryMap { data, response -> (Data, HTTPURLResponse) in
            guard let response = response as? HTTPURLResponse else {
                throw RESTWebError.responseUnknownFormat
            }
            
            return (data, response)
        }
        .mapError { $0 as! RESTWebError }
        .eraseToAnyPublisher()
    }
    
    func tryCheckHTTPSuccessCodes() -> AnyPublisher<Self.Output, RESTWebError>
    where Self.Output == (Data, HTTPURLResponse) {
        tryFilter { (data: Data, response: HTTPURLResponse) in
            let code = response.statusCode
            guard HTTPStatusCodes.success.contains(response.statusCode) else {
                if code == HTTPStatusCode.unauthorized {
                    throw RESTWebError.unauthorized
                }
                var reason = RESTWebError.BackendError.unknownReasonPlaceholder
                if !data.isEmpty, let backendReason = String(data: data, encoding: .utf8) {
                    reason = backendReason
                }
                throw RESTWebError.backend(.init(code: code, reason: reason, faultCode: nil))
            }
            return true
        }
        .mapError { $0 as! RESTWebError }
        .eraseToAnyPublisher()
    }
    
    func tryMapToMimeType() -> AnyPublisher<(Data, MIMEType), RESTWebError>
    where Self.Output == (Data, HTTPURLResponse) {
        tryMap { (data: Data, httpURLResponse: HTTPURLResponse) in
            guard let mimeType = httpURLResponse.mimeType,
                  let mimeType = MIMEType(rawValue: mimeType) else {
                throw RESTWebError.responseUnsupportedMimeType(httpURLResponse.mimeType)
            }
            
            return (data, mimeType)
        }
        .mapError { $0 as! RESTWebError }
        .eraseToAnyPublisher()
    }
    
    func tryDecode<T: APIResponse>(to type: T.Type,
                                   jsonDecoder: JSONDecoder) -> AnyPublisher<T, RESTWebError>
    where Self.Output == (Data, MIMEType) {
        tryMap { data, mimeType in
            switch mimeType {
            case .json: return try jsonDecoder.decode(type, from: data)
            case .plain: return String(data: data, encoding: .utf8) as! T
            }
        }
        .mapError { .responseDecodingFailed($0) }
        .eraseToAnyPublisher()
    }
}
