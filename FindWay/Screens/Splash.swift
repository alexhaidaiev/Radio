//
//  Splash.swift
//  FindWay
//
//  Created by Oleksandr Haidaiev on 01.04.2023.
//

import Foundation
import SwiftUI

fileprivate typealias Config = AppState.RemoteConfiguration

struct Splash<V: View>: View {
    @ViewBuilder let destination: () -> V
    
    private var appState: Store<AppState> { diContainer.appState }
    
    @Environment(\.injectedDI) private var diContainer: DIContainer
    @State private var isShowMainScreen = false
    
    var body: some View {
        if isShowMainScreen {
            destination()
        } else {
            VStack {
                Text("Loading remote configuration")
                ProgressView()
                    .onAppear {
                        // WARNING: it doesn't work in SwiftUI previews
                        Task {
                            // API request emulation
                            try await Task.sleep(until: .now + .seconds(0.8), clock: .continuous)
                            // API response emulation
                            appState[\.remoteConfig] = Config(currency: .init(symbol: "$",
                                                                              description: "USD"))
                        }
                    }
                    .onReceive(appState.publisher(for: \.remoteConfig).dropFirst(),
                               perform: { _ in isShowMainScreen = true }
                    )
            }
        }
    }
}

struct Splash_Previews: PreviewProvider, PreviewProviderWrapper {
    static var previewsWrap: some View {
        previewWithBinding(initialValue: (di: DIContainer.mockedSwiftUI, isShow: true)) { tuple in
            Splash() {
                VStack {
                    Text("""
                Splash screen ended
                currency: \(tuple.wrappedValue.di.appState[\.remoteConfig].currency.symbol)
                abbreviation: \(tuple.wrappedValue.di.appState[\.remoteConfig].currency.description)
                """)
                    .multilineTextAlignment(.center)
                }
            }.overlay {
                if tuple.wrappedValue.isShow {
                    Button("Emulate response") {
                        tuple.wrappedValue.isShow.toggle()
                        tuple.wrappedValue.di.appState[\.remoteConfig] =
                        Config(currency: .init(symbol: "£", description: "LBS"))
                    }
                    .offset(y: 170)
                }
            }
        }
    }
}
