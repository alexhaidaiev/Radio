//
//  CommonViewModifiers.swift
//  FindWay
//
//  Created by Oleksandr Haidaiev on 03.04.2023.
//

import SwiftUI

extension TextField {
    enum ModifierType {
        case standard
    }
    
    func commonModifier(_ type: ModifierType = .standard) -> some View {
        switch type {
        case .standard: return self.modifier(CommonRoundedTextField())
        }
    }
}
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
extension Text {
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

// MARK: TextFields

fileprivate struct CommonRoundedTextField: ViewModifier {
    func body(content: Content) -> some View {
        content
            .autocapitalization(.none)
            .font(.title2)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(Color(.systemGray5))
            )
    }
}

// MARK: Buttons

fileprivate struct CommonMainActionButtonStyle: ViewModifier {
    let isEnabled: Bool
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .padding()
            .frame(height: 44)
            .background(isEnabled ? Color.blue : Color.gray)
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
            // TODO: create a wrap for AssetCatalog colors and use it like `R.Color.Action.secondary`
            .background(isEnabled ? Color("SecondaryAction") : Color.gray)
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
            .background(isEnabled ? Color.red : Color.gray)
            .cornerRadius(8)
    }
}

struct ViewModifiers_Previews: PreviewProvider, PreviewProviderWrapper {
    static var previewsWrap: some View {
        previewWithBinding(initialValue: "") { text in
            VStack(spacing: 20) {
                TextField("Placeholder", text: text)
                    .commonModifier()
                
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
