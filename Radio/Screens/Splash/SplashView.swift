//
//  SplashView.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 16.04.2023.
//

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
                        // TODO: move this logic to the VM
                        Task {
                            // API request emulation
                            try await Task.sleep(until: .now + .seconds(0.8), clock: .continuous)
                            // API response emulation
                            appState[\.remoteConfig] = .fakeRemoteConf
                        }
                    }
                    .onReceive(appState.publisher(for: \.remoteConfig).dropFirst(),
                               perform: { _ in isShowMainScreen = true }
                    )
            }
        }
    }
}

struct Splash_Previews: PreviewProvider, GeneralPreview {
    static var previewsWithGeneralSetup: some View {
        previewWithBinding(initialValue: (di: DIContainer.mockedSwiftUI, isShow: true)) { tuple in
            Splash() {
                VStack {
                    Text("""
                Splash screen ended
                terms: \(tuple.wrappedValue.di
                .appState[\.remoteConfig]
                .termsAndConditionsLink?.absoluteString ?? "no link")
                password: \(tuple.wrappedValue.di
                .appState[\.remoteConfig].signInPasswordRegex)
                """)
                    .multilineTextAlignment(.center)
                }
            }.overlay {
                if tuple.wrappedValue.isShow {
                    Button("Emulate response") {
                        tuple.wrappedValue.di.appState[\.remoteConfig] = .fakeRemoteConf
                        tuple.wrappedValue.isShow.toggle()
                    }
                    .offset(y: 170)
                }
            }
        }
    }
}

