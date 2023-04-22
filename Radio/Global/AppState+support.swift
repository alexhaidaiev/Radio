//
//  AppState+support.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 21.04.2023.
//

import UIKit

extension AppState.Environment: CustomStringConvertible {
    var description: String {
        switch self {
        case .debug: return "Debug"
        case .qa: return "QA"
        case .prod: return "Prod"
        }
    }
}

extension AppState.Settings {
    static var systemIsDarkMode: Bool { UITraitCollection.current.userInterfaceStyle == .dark }
}
