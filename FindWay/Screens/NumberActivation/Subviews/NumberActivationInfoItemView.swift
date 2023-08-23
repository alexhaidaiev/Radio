//
//  NumberActivationInfoItemView.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 16.08.2023.
//

import SwiftUI

struct NumberActivationInfoItemView: View {
    struct Model: Identifiable {
        private(set) var id = UUID()
        let title: String
        let details: String
        let image: String
        let description: String
    }
    
    let model: Model
    
    var body: some View {
        VStack {
            Text(model.title)
                .font(.title)
                .fontWeight(.bold)
            Text(model.details)
                .fontWeight(.semibold)
            
            Spacer()
            Image(systemName: model.image)
                .resizable()
                .frame(width: 70, height: 70)
                .fixedSize()
            Spacer()
            
            Text(model.description)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 200)
                .offset(y: -32)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .foregroundColor(.white)
        .background(Gradient(colors: [.blue, .blue.opacity(0.7)]))
    }
}

struct NumberActivationInfoItemView_Previews: PreviewProvider {
    static var previews: some View {
        NumberActivationInfoItemView(model: .Mock.info1)
            .frame(height: 400)
            .previewLayout(.sizeThatFits)
    }
}
