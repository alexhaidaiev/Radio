//
//  ForUIDebugging.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 25.04.2023.
//

import SwiftUI

extension ShapeStyle where Self == Color {
    static var random: Color {
        Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}
