//
//  GeneralPreview.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 23.04.2023.
//

import SwiftUI

protocol GeneralPreview {
    associatedtype V: View
    @ViewBuilder static var previewsWithGeneralSetup: V { get }
    
    static var placeInNavigation: Bool { get }
}

extension GeneralPreview {
    static var placeInNavigation: Bool { false }
}

private let diForPreviewsShared: DIContainer = .mockedSwiftUI

extension PreviewProvider where Self: GeneralPreview {
    static var diForPreviews: DIContainer { diForPreviewsShared }
    static var setting: AppState.Settings { diForPreviews.appState[\.settings] }
    
    static var previews: some View {
        Group {
            if placeInNavigation {
                NavigationView {
                    previewsWithGeneralSetup
                        .navigationBarTitleDisplayMode(.inline)
                        .environment(\.injectedDI, diForPreviews)
                        .previewDisplayName("Base")
                    
                }
            } else {
                previewsWithGeneralSetup
                    .environment(\.injectedDI, diForPreviews)
                    .previewDisplayName("Base")
            }
        
            previewsWithGeneralSetup
                .environment(\.injectedDI, diForPreviews)
                .preferredColorScheme(setting.isDarkMode ? .dark : .dark)
            
                .environment(\.locale, .init(identifier: setting.languageCode))
                .environment(\.sizeCategory, .medium)
                .previewLayout(PreviewLayout.sizeThatFits)
                .previewDisplayName("Original size")
            // ... other common modifiers like devices, orientation, font sizes for all previews ...
        }
    }
}

// MARK: - Preview and Example

struct Test_Previews: PreviewProvider, GeneralPreview {
    static var placeInNavigation: Bool { true }
    static var previewsWithGeneralSetup: some View {
        TestDIInjectionView()
            .navigationTitle("In navigation example")
    }
    
    private struct TestDIInjectionView: View {
        @Environment(\.injectedDI) private var diContainer: DIContainer
        
        private var terms: String {
            diContainer.appState[\.remoteConfig].termsAndConditionsLink?.absoluteString ?? ""
        }
        
        var body: some View {
            VStack {
                Text("Environment - \(diContainer.appState[\.environment].description)")
                Text("Language - \(diContainer.appState[\.settings].languageCode)")
                Text("Terms - \(terms)")
            }
        }
    }
}
