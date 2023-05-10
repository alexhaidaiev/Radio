//
//  GlobalAccess.swift
//  FindWay
//
//  Created by Oleksandr Haidaiev on 02.04.2023.
//

import Foundation

var isTesting: Bool { ProcessInfo.processInfo.isTestsAreRunning }

@inlinable func assertionFailure<T>(_ message: String = "Shouldn't happen",
                                    toReturn: T,
                                    file: StaticString = #file,
                                    line: UInt = #line) -> T {
    assertionFailure(message, file: file, line: line)
    return toReturn
}

// NOTE: split later if needed
