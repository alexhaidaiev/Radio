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
        
        fileprivate static let unknownReasonPlaceholder = "No reason from the server side"
    }
    
    var asBackend: BackendError? {
        if case let .backend(error) = self { return error }
        return nil
    }
}

struct RESTWebRepository: WebRepository {
    let session: URLSession
    let requestBuilder: URLRequestBuilding

    func executeRequest<T: APIResponse>(endpoint: RESTEndpoint) -> AnyPublisher<T, RESTWebError> {
        requestBuilder.createRequest(from: endpoint)
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
    
    private func executeAndHandleURLRequest<T: APIResponse>(_ urlRequest: URLRequest,
                                                            responseType: APIResponse.Type)
    -> AnyPublisher<T, RESTWebError> {
        session
            .dataTaskPublisher(for: urlRequest)
            .mapError { $0.code == .timedOut ? .responseTimeOut : .responseURLError($0) }
            .tryMapToHTTPURLResponse()
            .tryCheckHTTPSuccessCodes()
            .tryMapToMimeType()
            .tryDecode(to: responseType as! T.Type)
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
        tryFilter { (data: Data, httpURLResponse: HTTPURLResponse) in
            let code = httpURLResponse.statusCode
            guard HTTPStatusCodes.success.contains(httpURLResponse.statusCode) else {
                if code == HTTPStatusCode.unauthorized {
                    throw RESTWebError.unauthorized
                }
                var reason = RESTWebError.BackendError.unknownReasonPlaceholder
                if !data.isEmpty, let backendReason = String(data: data, encoding: .utf8) {
                    reason = backendReason
                }
                throw RESTWebError.backend(.init(code: code, reason: reason))
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
    
    func tryDecode<T: APIResponse>(to type: T.Type) -> AnyPublisher<T, RESTWebError>
    where Self.Output == (Data, MIMEType) {
        tryMap { data, mimeType in
            switch mimeType {
            case .json: return try JSONDecoder().decode(type, from: data)
            case .plain: return String(data: data, encoding: .utf8) as! T
            }
        }
        .mapError { .responseDecodingFailed($0) }
        .eraseToAnyPublisher()
    }
}
