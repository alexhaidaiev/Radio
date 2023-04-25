//
//  TestingRelated.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 24.04.2023.
//

import Foundation

var isTesting: Bool { ProcessInfo.processInfo.isTestsAreRunning }
var isSwiftUIPreview: Bool { ProcessInfo.processInfo.isSwiftUIPreview }

extension ProcessInfo {
    var isTestsAreRunning: Bool { environment["XCTestConfigurationFilePath"] != nil }
    var isSwiftUIPreview: Bool { environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" }
}

import Combine

#if DEBUG
extension Publisher { // move to Fakes
    var fakeAPIDelay: AnyPublisher<Self.Output, Self.Failure> {
        let delay = isTesting ? GlobalConst.Fake.apiDelayForTests : GlobalConst.Fake.apiDelay
        return self
            .delayOnMain(delay)
            .eraseToAnyPublisher()
    }
}

extension GlobalConst.Fake {
    static let apiDelayForTests = 0.02
}
#endif
