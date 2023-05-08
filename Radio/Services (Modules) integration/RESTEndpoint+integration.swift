//
//  RESTEndpoint+integration.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 16.04.2023.
//

import Foundation

extension RESTEndpoint {
    // Default values
    var httpMethod: HTTPMethod { .get }
    var queryParameters: [QueryParameter] { [] }
    var acceptType: MIMEType {.json }
    var contentType: MIMEType { .json }
    func body() throws -> Data? { nil }
}

extension RESTEndpoint.QueryParameter {
    static var renderAsJson: Self { .init(name: "render", value: "json") }
    static func language(_ value: String) -> Self { .init(name: "ln", value: value) }
}
