//
//  ProcessInfo+helpers.swift
//  FindWay
//
//  Created by Oleksandr Haidaiev on 09.04.2023.
//

import Foundation

extension ProcessInfo {
    var isTestsAreRunning: Bool { environment["XCTestConfigurationFilePath"] != nil }
}
