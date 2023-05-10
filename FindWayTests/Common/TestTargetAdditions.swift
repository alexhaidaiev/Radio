//
//  TestTargetAdditions.swift
//  FindWayTests
//
//  Created by Oleksandr Haidaiev on 12.04.2023.
//

import Foundation
@testable import FindWay

extension APIError {
    static let forTesting: Self = .unexpectedResponse
}

enum TestingError: ErrorWithUnwrapError {
    case some, noData
}
