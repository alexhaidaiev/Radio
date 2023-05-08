//
//  DebugMenuView.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 24.04.2023.
//

import SwiftUI

#if DEBUG
struct DebugMenuView: View {
    @Environment(\.injectedDI) private var diContainer: DIContainer
    @State private var selectedLanguage = "en" // TODO: add sync with `appState`
    @State private var selectedEnvironment = "debug"
    
    // WARNING: this won't apply to already created screens, including destinations of navigations.
    // Find a way how to update them as well
    private var isOfflineMode: Binding<Bool> {
        Binding(to: diContainer.appState, for: \.debugFeatures.isOfflineMode)
    }
    private var isDarkMode: Binding<Bool> {
        Binding(to: diContainer.appState, for: \.settings.isDarkMode)
    }
    
    let closeAction: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            Spacer()
            
            Text("Debug settings")
                .font(.headline)
            Divider()
            
            togglesSection
            pickersSection
            buttonsSection
            
            Spacer()
            
            closeButton
        }
    }
    
    private var togglesSection: some View {
        VStack(spacing: 12) {
            Toggle("Offline mode active", isOn: isOfflineMode)
            Toggle("Dark mode", isOn: isDarkMode)
        }
        .padding(.vertical)
    }
    
    private var pickersSection: some View {
        VStack {
            HStack {
                Text("Device language:")
                Picker(selection: $selectedLanguage, label: Text("Language")) {
                    Text("English").tag("en")
                    Text("Deutsch").tag("de")
                    Text("Polski").tag("pl")
                }
                .pickerStyle(.menu)
                .disabled(true) // TODO: add sync with `appState`
            }
            HStack {
                Text("Environment (Backend):")
                Picker(selection: $selectedEnvironment, label: Text("Environment")) {
                    Text("Debug").tag("debug")
                    Text("QA").tag("qa")
                    Text("Prod").tag("prod")
                }
                .pickerStyle(.menu)
                .disabled(true) // TODO: add sync with `appState`
            }
        }
        .padding(.bottom)
    }
    
    private var buttonsSection: some View {
        VStack(spacing: 12) {
            Button(action: { }) { // TODO: implement some logic later
                Text("Reset caches")
                    .frame(maxWidth: .infinity)
            }
            .commonModifier(.distractive())

        }
        .frame(width: 260)
    }
    
    private var closeButton: some View {
        Button(action: closeAction) {
            Text("Close")
                .frame(maxWidth: .infinity)
        }
        .commonModifier(.mainAction())
    }
}

struct DebugMenuView_Previews: PreviewProvider, GeneralPreview {
    static var previewsWithGeneralSetup: some View {
        DebugMenuView(closeAction: { })
            .padding()
    }
}
#endif
