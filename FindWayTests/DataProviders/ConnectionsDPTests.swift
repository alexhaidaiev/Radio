//
//  ConnectionsDPTests.swift
//  FindWayTests
//
//  Created by Oleksandr Haidaiev on 23.03.2023.
//

import XCTest
@testable import FindWay

class ConnectionsDataProviderTests: XCTestCase {
    let cancellable = CancellableContainer()
    
    func testGetConnectionsSuccess() {
        let expectation = expectation(description: #function)
        let sut = FakeConnectionsDataProvider()
        
        sut.getConnections().sinkWithResult { result in
            switch result {
            case .success(let data):
                XCTAssertEqual(data.nodes.count, 7)
            case .failure(let failure):
                XCTFail(failure.localizedDescription)
            }
            expectation.fulfill()
        }.store(in: cancellable)
        
        waitForExpectations()
    }
    
    func testGetConnectionsFail() {
        let expectation = expectation(description: #function)
        let error: APIError = .network
        let sut = FakeConnectionsDataProvider()
        sut.apiErrorToFailWith = error
        
        sut.getConnections().sinkWithResult { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let failure):
                XCTAssertEqual(failure, ConnectionsDataProviderError.general(api: error))
            }
            expectation.fulfill()
        }.store(in: cancellable)
        
        waitForExpectations()
    }
    
    func testConnectionsDataProviderErrorsMapping() {
        let error123: (code: Int, reason: String) = (code: 123, reason: "someReason")
        let error234: (code: Int, reason: String) = (code: 234, reason: "anotherReason")
        let errorMissed: (code: Int, reason: String) = (code: 555, reason: "unknownReason")
        let sut = FakeConnectionsDataProvider.self
        
        let result1 = sut.dataProviderErrorFrom(code: error123.code, reason: error123.reason)
        let result2 = sut.dataProviderErrorFrom(code: error234.code, reason: error234.reason)
        let result3 = sut.dataProviderErrorFrom(code: errorMissed.code, reason: errorMissed.reason)
        
        XCTAssertEqual(result1, .serviceUnavailable)
        XCTAssertEqual(result2, .tooManyRequests)
        XCTAssertNil(result3)
    }
}

extension FakeConnectionsDataProvider: ConnectionsDataProviderPrivateTesting {}

extension ConnectionsDataProviderTests {
    func testGetConnectionsAPIDataMapping() {
        let sut = FakeConnectionsDataProvider.self
        
        let graph1 = sut.privateMapApiConnectionsToGraph(.fakeConnections())
        let graph2 = sut.privateMapApiConnectionsToGraph(.fakeConnections(from: .londonTokyo))
        
        XCTAssertEqual(graph1.nodes.count, 7)
        XCTAssertEqual(graph1.getNode(for: "Cape Town")?.connections.count, 1)
        XCTAssertEqual(graph1.getNode(for: "London")?.connections.count, 3)
        XCTAssertEqual(graph1.getNode(for: "Los Angeles")?.connections.count, 1)
        XCTAssertEqual(graph1.getNode(for: "New York")?.connections.count, 1)
        XCTAssertEqual(graph1.getNode(for: "Porto")?.connections.count, 0)
        XCTAssertEqual(graph1.getNode(for: "Sydney")?.connections.count, 1)
        XCTAssertEqual(graph1.getNode(for: "Tokyo")?.connections.count, 2)
        XCTAssertEqual(graph1.availableFromCities, ["Cape Town", "London", "Los Angeles",
                                                    "New York", "Sydney", "Tokyo"])
        
        XCTAssertEqual(graph2.nodes.count, 5)
        XCTAssertEqual(graph2.getNode(for: "London")?.connections.count, 2)
        XCTAssertEqual(graph2.getNode(for: "London2")?.connections.count, 2)
        XCTAssertEqual(graph2.getNode(for: "Los Angeles")?.connections.count, 1)
        XCTAssertEqual(graph2.getNode(for: "New York")?.connections.count, 1)
        XCTAssertEqual(graph2.getNode(for: "Tokyo")?.connections.count, 0)
        XCTAssertEqual(graph2.availableToCities, ["Los Angeles", "New York", "Tokyo"])
    }
}
