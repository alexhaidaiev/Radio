//
//  DebugButtonWithDebugMenu.swift
//  FindWay
//
//  Created by Oleksandr Haidaiev on 01.04.2023.
//

import SwiftUI

struct DebugMenuButton<Content: View>: View {
    @Environment(\.injectedDI) private var diContainer: DIContainer
    @State private var isShowPopup = false
    
    let content: () -> Content
    
#if DEBUG
    var body: some View {
        ZStack {
            content()
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { isShowPopup = true }) {
                        buttonImage
                    }
                    .offset(y: -40)
                    .zIndex(100)
                }
            }
            Color.clear
                .bottomPopup(isPresented: $isShowPopup) {
                    DebugMenuView(closeAction: { isShowPopup = false })
                        .frame(maxHeight: 600)
                }
        }
    }
#else
    var body: some View {
        content()
    }
#endif
    
    private var buttonImage: some View {
        Image(systemName: "gearshape")
            .foregroundColor(.white)
            .font(.system(size: 24))
            .padding(10)
            .background(Color.black.opacity(0.3))
            .clipShape(Circle())
            .padding(10)
    }
}

struct DebugMenuButton_Previews: PreviewProvider, PreviewProviderWrapper {
    static var previewsWrap: some View {
        DebugMenuButton() {
            Text("Hello")
        }
    }
}
