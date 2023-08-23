//
//  NumberActivationScreen.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 16.08.2023.
//

import SwiftUI

extension NumberActivationView {
    class VM: ObservableObject {
        @Published var paymentOptions: NumberActivationPaymentOptionsView.Model
        
        let infoItems: [NumberActivationInfoItemView.Model]
        let activateButtonTitle: String
        let activateButtonAction: () -> Void
        
        init(paymentOptions: NumberActivationPaymentOptionsView.Model,
             infoItems: [NumberActivationInfoItemView.Model],
             activateButtonTitle: String,
             activateButtonAction: @escaping () -> Void) {
            self.paymentOptions = paymentOptions
            self.infoItems = infoItems
            self.activateButtonTitle = activateButtonTitle
            self.activateButtonAction = activateButtonAction
        }
    }
}

struct NumberActivationView: View {
    @ObservedObject var vm: VM
    
    var body: some View {
        NavigationView {
            content
                .navigationTitle("+1 572 6832 832")
                .navigationBarTitleDisplayMode(.inline )
        }
    }
    
    @ViewBuilder
    private var content: some View {
        GeometryReader { geo in
            ScrollView {
                VStack {
                    TabView {
                        ForEach(vm.infoItems) { item in
                            NumberActivationInfoItemView(model: item)
                        }
                    }
                    .frame(height: geo.size.height * 0.6)
                    .tabViewStyle(.page)
                    .indexViewStyle(.page(backgroundDisplayMode: .never))
                    
                    NumberActivationPaymentOptionsView(model: vm.paymentOptions) { option in
                        
                    }
                    Spacer()
                    
                    Button(action: vm.activateButtonAction) {
                        Text(vm.activateButtonTitle)
                            .foregroundColor(.white)
                            .font(.title)
                            .padding(.horizontal, 24)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(30)
                    }
                }
            }
            .frame(maxHeight: UIScreen.main.bounds.height)
        }
    }
}

struct NumberActivationView_Previews: PreviewProvider {
    static var previews: some View {
        NumberActivationView(vm: .Mock.main)
    }
}
