//
//  NumberActivationMocks.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 16.08.2023.
//

import Foundation

extension NumberActivationView.VM {
    typealias VM = NumberActivationView.VM
    
    enum Mock {
        static let main: VM = .init(
            paymentOptions: .Mock.all,
            infoItems: [.Mock.info1, .Mock.info2, .Mock.info3, .Mock.info4],
            activateButtonTitle: "ACTIVATE",
            activateButtonAction: { }
        )
    }
}

// MARK: - Info section

extension NumberActivationInfoItemView.Model {
    typealias Info = NumberActivationInfoItemView.Model
    
    enum Mock {
        static let info1: Info = .init(title: "Real number",
                                       details: "Contact ...",
                                       image: "phone.circle.fill",
                                       description: "Lorem ipsu Lorem ipsu Lorem ipsu Lorem ipsu")
        static let info2: Info = .init(title: "Real number 2",
                                       details: "Contact ...",
                                       image: "phone.circle.fill",
                                       description: "Lorem ipsu Lorem ipsu Lorem ipsu Lorem ipsu")
        static let info3: Info = .init(title: "Real number 3",
                                       details: "Contact ...",
                                       image: "phone.circle.fill",
                                       description: "Lorem ipsu Lorem ipsu Lorem ipsu Lorem ipsu")
        static let info4: Info = .init(title: "Real number 4",
                                       details: "Contact ...",
                                       image: "phone.circle.fill",
                                       description: "Lorem ipsu Lorem ipsu Lorem ipsu Lorem ipsu")
    }
}

// MARK: - Payment section

extension NumberActivationPaymentOptionsView.Model {
    typealias M = NumberActivationPaymentOptionsView.Model
    
    enum Mock {
        static let all: M = .init(options: [.Mock.months3, .Mock.days3, .Mock.months12])
    }
}

extension NumberActivationPaymentItemView.Model {
    typealias Option = NumberActivationPaymentItemView.Model
    
    enum Mock {
        static let months3: Option = .init(title: "3",
                                           details: "months",
                                           price: "$29.99")
        static let days3: Option = .init(title: "3-Day",
                                         details: "trial",
                                         price: "$7.99/wk",
                                         isActive: true)
        static let months12: Option = .init(title: "12",
                                            details: "months",
                                            price: "$59.99")
    }
}
