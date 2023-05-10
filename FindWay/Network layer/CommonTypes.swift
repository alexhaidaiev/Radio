//
//  CommonTypes.swift
//  FindWay
//
//  Created by Oleksandr Haidaiev on 26.03.2023.
//

import Foundation

typealias HTTPCode = Int
typealias HTTPCodes = Range<HTTPCode>

extension HTTPCodes {
    static let success = 200..<300
    static let unauthorized = 401
    // ... etc
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
    case plain = "text/plain"
}
