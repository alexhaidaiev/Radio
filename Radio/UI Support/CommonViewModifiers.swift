//
//  CommonViewModifiers.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 24.04.2023.
//

import SwiftUI

extension Button {
    enum ModifierType {
        case mainAction(isEnabled: Bool = true)
        case secondaryAction(isEnabled: Bool = true)
        case distractive(isEnabled: Bool = true)
    }
    
    @ViewBuilder
    func commonModifier(_ type: ModifierType = .mainAction(isEnabled: true)) -> some View {
        switch type {
        case .mainAction(let isEnabled):
            self.modifier(CommonMainActionButtonStyle(isEnabled: isEnabled))
        case .secondaryAction(let isEnabled):
            self.modifier(CommonSecondaryActionButtonStyle(isEnabled: isEnabled))
        case .distractive(let isEnabled):
            self.modifier(CommonDistractiveButtonStyle(isEnabled: isEnabled))
        }
    }
}

fileprivate struct CommonMainActionButtonStyle: ViewModifier {
    let isEnabled: Bool
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .padding()
            .frame(height: 44)
            .background(isEnabled ? Color.blue : .gray)
            .cornerRadius(8)
    }
}

fileprivate struct CommonSecondaryActionButtonStyle: ViewModifier {
    let isEnabled: Bool
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .padding()
            .frame(height: 44)
            .background(isEnabled ? Color.orange : .gray)
            .cornerRadius(8)
    }
}

fileprivate struct CommonDistractiveButtonStyle: ViewModifier {
    let isEnabled: Bool
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .padding()
            .frame(height: 44)
            .background(isEnabled ? Color.red : .gray)
            .cornerRadius(8)
    }
}

// MARK: - Preview

struct ViewModifiers_Previews: PreviewProvider, GeneralPreview {
    static var previewsWithGeneralSetup: some View {
        previewWithBinding(initialValue: "") { text in
            VStack(spacing: 20) {
                Button(action: { }, label: {
                    Text("Delete")
                        .frame(maxWidth: .infinity)
                })
                .commonModifier(.distractive())
                
                Button(action: { }, label: {
                    Text("Secondary action")
                        .frame(maxWidth: .infinity)
                })
                .commonModifier(.secondaryAction())
                
                Button(action: { }, label: {
                    Text("Confirm")
                        .frame(maxWidth: .infinity)
                })
                .commonModifier(.mainAction())
            }
            .padding()
        }
    }
}
