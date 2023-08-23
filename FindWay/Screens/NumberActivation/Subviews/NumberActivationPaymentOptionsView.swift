//
//  NumberActivationPaymentOptionsView.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 16.08.2023.
//

import Foundation
import SwiftUI

struct NumberActivationPaymentOptionsView: View {
    typealias Option = NumberActivationPaymentItemView.Model
    
    struct Model {
        let options: [Option]
    }
    
    let model: Model
    let onSelectOption: (Option) -> Void
    
    var body: some View {
        HStack {
            ForEach(model.options) { option in
                NumberActivationPaymentItemView(model: option) {
                    onSelectOption(option)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
    }
}

struct NumberActivationPaymentOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        NumberActivationPaymentOptionsView(model: .Mock.all) { _ in }
    }
}
