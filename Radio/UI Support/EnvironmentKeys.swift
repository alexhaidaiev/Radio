//
//  EnvironmentKeys.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 23.04.2023.
//

import SwiftUI

struct InjectedDIContainer: EnvironmentKey {
    static let defaultValue: DIContainer = .defaultValue
}

extension EnvironmentValues {
    var injectedDI: DIContainer {
        get { self[InjectedDIContainer.self] }
        set { self[InjectedDIContainer.self] = newValue }
    }
}
