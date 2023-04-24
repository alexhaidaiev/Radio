//
//  RadioApp.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 15.04.2023.
//

import SwiftUI

@main
struct RadioApp: App {
    private var diContainer: DIContainer = .defaultValue
    @State private var preferredColorScheme: ColorScheme = .light
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.injectedDI, diContainer)
                .preferredColorScheme(preferredColorScheme)
                .onReceive(diContainer.appState.publisher(for: \.settings.isDarkMode).dropFirst(),
                           perform: { isDarkMode in
                    preferredColorScheme = isDarkMode ? .dark : .light
                })
        }
    }
}

struct RootView: View {
    @Environment(\.injectedDI) private var diContainer: DIContainer
    
    var body: some View {
        DebugMenuButton() {
            Splash() {
                HomeScreen(viewModel: HomeViewModel(di: diContainer))
            }
        }
    }
}

struct RootView_Previews: PreviewProvider, GeneralPreview {
    static var previewsWithGeneralSetup: some View {
        RootView()
    }
}
