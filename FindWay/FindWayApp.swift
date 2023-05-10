//
//  FindWayApp.swift
//  FindWay
//
//  Created by Oleksandr Haidaiev on 10.05.2023.
//

import SwiftUI

@main
struct FindWayApp: App {
    private var diContainer: DIContainer = InjectedDIContainer.defaultValue
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
                FindWayView(viewModel: FindWayViewModel(diContainer: diContainer))
            }
        }
    }
}

struct RootView_Previews: PreviewProvider, PreviewProviderWrapper {
    static var previewsWrap: some View {
        RootView()
    }
}
