//
//  HTTPTypes.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 16.04.2023.
//

typealias HTTPStatusCode = Int
typealias HTTPStatusCodes = Range<HTTPStatusCode>

extension HTTPStatusCode {
    static let badRequest = 400
    static let unauthorized = 401
    static let forbidden = 403
    static let notFound = 404
    
    static let internalServerError = 500
    static let serviceUnavailable = 503
    // ... etc
}

extension HTTPStatusCodes {
    static let success = 200..<300
    static let redirect = 300..<400
    static let clientError = 400..<500
    static let serverError = 500..<600
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

enum HTTPHeaderField: String {
    case contentType = "Content-Type"
    case acceptMIME = "Accept"
    case contentLength = "Content-Length"
}

enum MIMEType: String {
    case json = "application/json"
//    case xml = "text/xml" // not supported yet
    case plain = "text/plain"
}
