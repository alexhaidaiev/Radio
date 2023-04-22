//
//  RadioApp.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 15.04.2023.
//

import SwiftUI

let tempDI = DIContainer.debug

@main
struct RadioApp: App {
    var body: some Scene {
        WindowGroup {
            HomeScreen(viewModel: HomeViewModel(di: tempDI))
        }
    }
}
