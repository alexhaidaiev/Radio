//
//  RESTEndpoint.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 16.04.2023.
//

import Foundation

protocol RESTEndpoint {
    typealias QueryParameter = URLQueryItem
    
    var responseType: APIResponse.Type { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var queryParameters: [QueryParameter] { get }
    var acceptType: MIMEType { get }
    var contentType: MIMEType { get }
    func body() throws -> Data?
    
    func combinedQueryParamWith(common: [QueryParameter]) -> [QueryParameter]
}

extension RESTEndpoint {
    /// Override to  provide your realisation if needed
    func combinedQueryParamWith(common: [QueryParameter]) -> [QueryParameter] {
        return queryParameters + common
    }
}
