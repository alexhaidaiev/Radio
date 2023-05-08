//
//  JSONDecoder+integration.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 05.05.2023.
//

import Foundation

extension JSONDecoder {
    static let standard: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}
