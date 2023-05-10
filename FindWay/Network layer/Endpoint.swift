//
//  Endpoint.swift
//  FindWay
//
//  Created by Oleksandr Haidaiev on 26.03.2023.
//

import Foundation

protocol Endpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: [URLQueryItem] { get }
    var acceptType: MIMEType { get }
    var contentType: MIMEType { get }
    func body() throws -> Data?
}
extension Endpoint {
    // Default values
    var method: HTTPMethod { .get }
    var parameters: [URLQueryItem] { [] }
    var acceptType: MIMEType {.json }
    var contentType: MIMEType { .json }
    func body() throws -> Data? { nil }
}
