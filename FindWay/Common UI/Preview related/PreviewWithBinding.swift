//
//  PreviewWithBinding.swift
//  FindWay
//
//  Created by Oleksandr Haidaiev on 03.04.2023.
//

import SwiftUI

extension PreviewProvider {
    static func previewWithBinding<Value, Destination: View>(
        initialValue: Value,
        content: @escaping (Binding<Value>) -> Destination) -> some View {
        PreviewWithBinding(initialValue: initialValue, content: content)
    }
}
fileprivate struct PreviewWithBinding<Value, Destination: View>: View {
    @State private var value: Value
    @ViewBuilder let content: (Binding<Value>) -> Destination
    
    init(initialValue: Value, content: @escaping (Binding<Value>) -> Destination) {
        self._value = State(initialValue: initialValue)
        self.content = content
    }
    
    var body: some View {
        content($value)
    }
}
