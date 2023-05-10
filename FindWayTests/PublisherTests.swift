//
//  PublisherTests.swift
//  FindWayTests
//
//  Created by Oleksandr Haidaiev on 15.04.2023.
//

import Combine
import XCTest

@testable import FindWay

class PublisherTests: XCTestCase {
    private let cancellable = CancellableContainer()
    
    func testUnwrapOrThrowSuccess() throws {
        let sut = JustWithError<Int?, TestingError>(1)
        
        let publisher = sut.unwrap(orThrow: TestingError.noData)
        
        executePublisherWithTimeOut(publisher) { result in
            switch result {
            case .success(let value):
                XCTAssertEqual(value, 1)
            case .failure:
                XCTFail()
            }
        }
    }
    
    func testUnwrapOrThrowFail() throws {
        let sut = JustWithError<Int?, TestingError>(nil)
        let someError: TestingError = .noData
        
        let publisher = sut.unwrap(orThrow: someError)
        
        executePublisherWithTimeOut(publisher) { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, someError)
            }
        }
    }
}

