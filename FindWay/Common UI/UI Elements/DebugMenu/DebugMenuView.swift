//
//  DebugMenuView.swift
//  FindWay
//
//  Created by Oleksandr Haidaiev on 02.04.2023.
//

import SwiftUI

#if DEBUG
struct DebugMenuView: View {
    @Environment(\.injectedDI) private var diContainer: DIContainer
    @State private var selectedLanguage = "en"
    @State private var selectedEnvironment = "debug"
    
    private var isFakeConnections: Binding<Bool> {
        Binding(to: diContainer.appState, for: \.debugConfig.isUseFakeConnections)
    }
    private var isFakeDetails: Binding<Bool> { .constant(false) } // TODO
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
            Toggle("Use fake data for connections", isOn: isFakeConnections)
            Toggle("Use fake data for details", isOn: isFakeDetails)
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
                .disabled(true)
            }
            HStack {
                Text("Environment (Backend):")
                Picker(selection: $selectedEnvironment, label: Text("Environment")) {
                    Text("Debug").tag("debug")
                    Text("QA").tag("qa")
                    Text("Prod").tag("prod")
                }
                .pickerStyle(.menu)
                .disabled(true)
            }
        }
        .padding(.bottom)
    }
    
    private var buttonsSection: some View {
        VStack(spacing: 12) {
            Button(action: { }) { // TODO
                Text("Reset caches")
                    .frame(maxWidth: .infinity)
            }
            .commonModifier(.distractive())
            Button(action: { }) {
                Text("Log out")
                    .frame(maxWidth: .infinity)
            }
            .commonModifier(.distractive())
            Button(action: { }) {
                Text("Restart app")
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

struct DebugMenuView_Previews: PreviewProvider, PreviewProviderWrapper {
    static var previewsWrap: some View {
        DebugMenuView(closeAction: { })
            .padding()
    }
}
#endif
