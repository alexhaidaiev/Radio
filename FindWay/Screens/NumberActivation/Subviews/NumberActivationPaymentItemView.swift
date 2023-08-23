//
//  NumberActivationPaymentItemView.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 16.08.2023.
//

import SwiftUI

struct NumberActivationPaymentItemView: View {
    struct Model: Identifiable {
        private(set) var id = UUID()
        let title: String
        let details: String
        let price: String
        var isActive: Bool = false
    }
    
    let model: Model
    let onSelect: () -> Void
    
    var body: some View {
        VStack {
            Text(model.title)
                .font(.title)
                .fontWeight(.bold)
            Text(model.details)
            Text(model.price)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .foregroundColor(model.isActive ? .blue : .black)
        .onTapGesture {
            onSelect()
        }
    }
}

struct NumberActivationPaymentItemView_Previews: PreviewProvider {
    static var previews: some View {
        NumberActivationPaymentItemView(model: .Mock.days3) { }
    }
}
