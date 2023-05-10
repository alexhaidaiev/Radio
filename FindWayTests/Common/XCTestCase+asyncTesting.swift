//
//  XCTestCase+asyncTesting.swift
//  FindWayTests
//
//  Created by Oleksandr Haidaiev on 15.04.2023.
//

import XCTest
import Combine

extension XCTestCase {
    func waitForExpectations(handler: (@Sendable (Error?) -> Void)? = nil) {
        waitForExpectations(timeout: Const.expectationsTimeout, handler: handler)
    }
    
    func executePublisherWithTimeOut<P: Publisher, Output, Failure>(
        _ publisher: P,
        timeout: TimeInterval = Const.expectationsTimeout,
        description: String = #function,
        completion: (Result<Output, Failure>) -> Void)
    where Output == P.Output, Failure == P.Failure {
        
        var optionalResult: Result<Output, Failure>?
        let expectation = expectation(description: description)
        
        let cancellable = publisher.sink { completion in
            switch completion {
            case .failure(let error):
                optionalResult = .failure(error)
                expectation.fulfill()
            case .finished:
                break
            }
        } receiveValue: { output in
            optionalResult = .success(output)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout) { error in
            if error != nil {
                cancellable.cancel()
            }
        }
        if let optionalResult {
            completion(optionalResult)
        }
    }
    
    func executeAsyncWorkWithTimeout(_ timeout: TimeInterval = Const.expectationsTimeout,
                                     function: String = #function,
                                     file: StaticString = #filePath,
                                     line: UInt = #line,
                                     workItem: @escaping () async throws -> Void) {
        let expectation = expectation(description: function)
        var workItemError: Error?
        let captureError = { workItemError = $0 }
        
        let task = Task {
            do {
                try await workItem()
            }
            catch {
                captureError(error)
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: timeout) { _ in
            if let error = workItemError {
                XCTFail("\(error)", file: file, line: line)
            }
            task.cancel()
        }
    }
    
    /// Use it when you have several async tasks and you want to increase the default timeout time
    func withTimeout(defaultTimeoutMultiplier: Double,
                     function: String = #function,
                     file: StaticString = #filePath,
                     line: UInt = #line,
                     workItem: @escaping () async throws -> Void) {
        executeAsyncWorkWithTimeout(Const.expectationsTimeout * defaultTimeoutMultiplier,
                                    function: function,
                                    file: file,
                                    line: line,
                                    workItem: workItem)
    }
}
