//
//  TestingRelated.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 24.04.2023.
//

import Foundation

var isTesting: Bool { ProcessInfo.processInfo.isTestsAreRunning }
extension ProcessInfo {
    var isTestsAreRunning: Bool { environment["XCTestConfigurationFilePath"] != nil }
}

import Combine

extension Publisher {
#if DEBUG
    var fakeAPIDelay: AnyPublisher<Self.Output, Self.Failure> {
        let delay = isTesting ? GlobalConst.Fake.apiDelayForTests : GlobalConst.Fake.apiDelay
        return self
            .delayOnMain(delay)
            .eraseToAnyPublisher()
    }
#endif
}


#if DEBUG
extension GlobalConst.Fake {
    static let apiDelayForTests = 0.02
}
#endif
