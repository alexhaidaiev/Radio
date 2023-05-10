//
//  BottomPopupView.swift
//  FindWay
//
//  Created by Oleksandr Haidaiev on 02.04.2023.
//

import SwiftUI

struct BottomPopupView<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @Binding var isPresented: Bool
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .opacity(isPresented ? 1 : 0)
                    .onTapGesture { isPresented = false }
                VStack {
                    Spacer()
                    // TODO: add scroll if content too large
                    content()
                        .padding(.bottom, geometry.safeAreaInsets.bottom)
                        .padding()
                        .frame(width: min(400, geometry.size.width))
                        .frame(minHeight: 200)
                        .background(colorScheme == .dark ? Color.gray : .white)
                        .clipShape(TopRoundedCorners(topLeftRadius: 12, topRightRadius: 12))
                        .shadow(radius: 15)
                        .offset(y: isPresented ? 0 : UIScreen.main.bounds.height)
                }
                .ignoresSafeArea()
            }
            .animation(.easeInOut(duration: 0.3), value: isPresented)
        }
    }
}

extension View {
    func bottomPopup<PopupContent: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> PopupContent
    ) -> some View {
        self.modifier(PopupViewModifier(isPresented: isPresented, content: content))
    }
}
fileprivate struct PopupViewModifier<PopupContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    var content: () -> PopupContent
    
    func body(content: Content) -> some View {
        BottomPopupView(isPresented: $isPresented, content: self.content)
            .ignoresSafeArea(.keyboard)
    }
}

// MARK: - Preview

struct PopupView_Previews: PreviewProvider, PreviewProviderWrapper {
    static var previewsWrap: some View {
        previewWithBinding(initialValue: true) { isShowPopup in
            ZStack {
                Button("Open popup") {
                    isShowPopup.wrappedValue = true
                }
                BottomPopupView(isPresented: isShowPopup) {
                    popupContent(closeAction: {
                        isShowPopup.wrappedValue = false
                    })
                }
            }
        }
    }
    
    static private func popupContent(closeAction: @escaping () -> Void) -> some View {
        VStack(spacing: 20) {
            Text("Click outside\nto close popup\nor the btn:")
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
            
            Button("Close") { closeAction() }
                .font(.title)
        }
        .padding()
        .background(Color.gray.opacity(0.4))
    }
}
