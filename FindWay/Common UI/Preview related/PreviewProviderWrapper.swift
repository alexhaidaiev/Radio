//
//  PreviewProviderWrapper.swift
//  FindWay
//
//  Created by Oleksandr Haidaiev on 29.03.2023.
//

import SwiftUI

protocol PreviewProviderWrapper {
    associatedtype V: View
    static var previewsWrap: V { get }
}

extension PreviewProvider where Self: PreviewProviderWrapper {
    static var defaultDIForPreviews: DIContainer { .mockedSwiftUI }
    
    static var previews: some View {
        previewsWrap
            .environment(\.injectedDI, defaultDIForPreviews)
            // Uncomment what you want to test globally
//            .preferredColorScheme(.dark)
            // ... other common wrappers like devices, orientation for all previews, etc
    }
}

// MARK: - Preview & Example

struct Test_Previews: PreviewProvider, PreviewProviderWrapper {
    // When we use `previewsWrap` instead `previews` we automatically add
    // all common previews features
    static var previewsWrap: some View {
        TestDIInjectionView()
    }
    
    private struct TestDIInjectionView: View {
        @Environment(\.injectedDI) private var diContainer: DIContainer
        
        var body: some View {
            Text("Environment is - \(diContainer.appState[\.environment].description)")
        }
    }
}

/* Alternative realization
extension PreviewProviderWrapper { //where V: PreviewProvider  {
    static var previews: some View {
        PreviewWrapper(diContainer: .mockedSwiftUI) {
            previewsWrap
        }
    }
}

private struct PreviewWrapper<T: View>: View {
    var diContainer: DIContainer
    let content: () -> T
    
    var body: some View {
        content()
            .environment(\.injectedDI, diContainer)
    }
}
*/
