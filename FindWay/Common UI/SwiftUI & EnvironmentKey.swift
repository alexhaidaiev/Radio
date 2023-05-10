//
//  SwiftUI & EnvironmentKey.swift
//  FindWay
//
//  Created by Oleksandr Haidaiev on 29.03.2023.
//

import Foundation
import SwiftUI

struct InjectedDIContainer: EnvironmentKey {
#if DEBUG
    static let defaultValue: DIContainer = .mocked
#else
    static let defaultValue: DIContainer = .real
#endif
}

extension EnvironmentValues {
    var injectedDI: DIContainer {
        get { self[InjectedDIContainer.self] }
        set { self[InjectedDIContainer.self] = newValue }
    }
}
