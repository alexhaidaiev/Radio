//
//  UIKit+helpers.swift
//  FindWay
//
//  Created by Oleksandr Haidaiev on 03.04.2023.
//

import UIKit

extension AppState.Settings {
    static var sytemIsDarkMode: Bool { UITraitCollection.current.userInterfaceStyle == .dark }
}
