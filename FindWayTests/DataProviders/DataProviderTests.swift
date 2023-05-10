//
//  DataProviderTests.swift
//  FindWayTests
//
//  Created by Oleksandr Haidaiev on 11.04.2023.
//

import XCTest
@testable import FindWay

class DataProviderTests: XCTestCase {
    func testDataProviderErrorsMapping() {
        let errorUnknown: APIError = .forTesting
        let errorReal: APIError = .backend(.concrete(code: 777, reason: "some777Reason"))
        let errorMissed: APIError = .backend(.concrete(code: 555, reason: "someUnknownReason"))
        let sut = SomeDataProvider.self
        
        let someError1 = sut.mapErrors(errorUnknown)
        let someError2 = sut.mapErrors(errorReal)
        let someError3 = sut.mapErrors(errorMissed)
        
        XCTAssertEqual(someError1, .general(api: errorUnknown))
        XCTAssertEqual(someError2, .someSpecific)
        XCTAssertEqual(someError3, .general(api: errorMissed))
    }
}

enum SomeDataProviderError: ErrorWithGeneralAPIError, Equatable {
    case general(api: APIError)
    case someSpecific
}

struct SomeDataProvider: DataProvider {
    static func dataProviderErrorFrom(code: Int, reason: String) -> SomeDataProviderError? {
        switch code {
        case 777 where reason == "some777Reason": return .someSpecific
        default: return nil
        }
    }
}

