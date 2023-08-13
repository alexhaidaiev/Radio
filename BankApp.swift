//
//  BankApp.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 12.08.2023.
//

import Foundation

// Application

struct SomeCountryTarget1 {
    
}
struct SomeCountryTarget2 {
    
}

// TODO: move entities to appropriate modules and files
// MARK: Features modules

class TopUpFeature {
    
}
class TransferToCardFeature { }
class AchievementsFeature { }

struct TopUpRootOperator {
    let sharedServices: SharedServices
    let vm: TopUpRootVMCommon
}

// MARK: Core services module

protocol NetworkService {
    
}

struct SharedServices {
    let networkService: NetworkService
}

// MARK: Domain module

typealias CardId = String

enum Domain {
    struct CardFullData { // TODO: extract to `enum Card`
        enum PhysicalType {
            case physical, digitalOnly
        }
        
        let mainInfo: CardMainData
        let privateData: CardPrivateData?
        let physicalType: PhysicalType
    }
    
    struct CardMainData {
        enum CardType {
            case credit, debit, government, child
            case otherBank
        }
        enum Currency {
            case uah, usd, eur
        }
        
        let id: CardId
        let type: CardType
        let currency: Currency
        let lastDigits: String
        let customName: String?
    }
    
    struct CardPrivateData {
        struct Owner {
            let name: String
            let surname: String
        }
        let fullNumber: String
        let expireDate: Date
        let owner: Owner
    }
}

// Top up part

enum TopUp {
    enum TopUpOption {
        case fromSavedCard, fromMyCard, fromOtherBankCard, byRequisites, byPaymentSystem
        case swift, sepa
    }
    
    struct State {
        struct Shared {
            let userCards: [Domain.CardMainData]
            let savedCards: [Domain.CardMainData]
        }
        
        let shared: Shared
        let availableOptions: [TopUp.TopUpOption]
        
        // Sub states
//        let topUpRootState: TopUpRootState
//        let topUpFromSavedCardState: TopUpFromSavedCardState
//        let topUpFromMyCardState: TopUpFromMyCardState
//        let topUpResultState: TopUpResultState
    }
}

//extension TopUp.State {
//    struct TopUpRootState {
//        let availableOptions: [TopUp.TopUpOptions]
//    }
//}

// MARK: - UI module

class TopUpRootVMCommon: TopUpRootView.VM {
    func handleNewState(_ state: TopUp.State) {
        title = "Top up current curd"
        availableSections = Self.availableSectionsFrom(
            options: state.availableOptions,
            userCards: state.shared.userCards,
            savedCards: state.shared.savedCards
        )
    }
    
    override func handleAction(_ action: TopUpRootView.VM.Action) {
        switch action {
        case .onAppear:
            break
        case .optionSelected(let option):
            selectedOption = option
        }
    }
    
    static func availableSectionsFrom(
        options: [TopUp.TopUpOption],
        userCards: [Domain.CardMainData],
        savedCards: [Domain.CardMainData]
    ) -> [AvailableSection] {
        var savedCardsSection: AvailableSection = .init(
            type: .savedCards,
            title: "Saved cards"
        )
        var myCardsSection: AvailableSection = .init(
            type: .myCards,
            title: "My cards"
        )
        var otherSection: AvailableSection = .init(
            type: .other,
            title: "Other methods"
        )
        
        options.forEach { option in
            switch option {
            case .fromSavedCard:
                savedCards.forEach {
                    savedCardsSection.items.append(
                        .init(title: $0.customName ?? "Card",
                              description: "* " + $0.lastDigits,
                              image: .name("saved_card.icon"))
                    )
                }
            case .fromMyCard:
                userCards.forEach {
                    if let item = myCardItemFrom(cardType: $0.type) {
                        myCardsSection.items.append(item)
                    }
                }
            case .fromOtherBankCard, .byRequisites, .byPaymentSystem, .swift, .sepa:
                if let item = otherItemFrom(option: option) {
                    otherSection.items.append(item)
                }
            }
        }
        return [savedCardsSection, myCardsSection, otherSection]
    }
    
    static func myCardItemFrom(cardType: Domain.CardMainData.CardType) -> TopUpOptionItemView.VM? {
        switch cardType {
        case .credit:
            return .init(title: "From my credit card", image: .name("credit_card.icon"))
        case .debit:
            return .init(title: "From my debit card", image: .name("debit_card.icon"))
        case .government:
            return .init(title: "From my government card", image: .name("government_card.icon"))
        case .child:
            return .init(title: "From my child card", image: .name("child_card.icon"))
        case .otherBank:
            return nil
        }
    }
    
    static func otherItemFrom(option: TopUp.TopUpOption) -> TopUpOptionItemView.VM? {
        switch option {
        case .fromSavedCard, .fromMyCard:
            return nil
        case .fromOtherBankCard:
            return .init(title: "From another card", image: .name("other_bank.icon"))
        case .byRequisites:
            return .init(title: "By requisites", image: .name("requisites.icon"))
        case .byPaymentSystem:
            return .init(title: "Apple pay", image: .name("applepay.icon"))
        case .swift:
            return .init(title: "SWIFT transfer", image: .name("swift.icon"))
        case .sepa:
            return .init(title: "SEPA transfer", image: .name("sepa.icon"))
        }
    }
}

// Screens
import SwiftUI

struct TopUpRootView: View {
    class VM: ObservableObject {
        struct AvailableSection {
            enum SectionType {
                case savedCards, myCards, other
            }
            
            let type: SectionType
            let title: String
            var items: [TopUpOptionItemView.VM] = []
        }
        
        enum Action {
            case onAppear
            case optionSelected(_ option: TopUpOptionItemView.VM)
        }
        func handleAction(_ action: Action) { }
        
        @Published fileprivate(set) var title: String = ""
        @Published fileprivate(set) var availableSections: [AvailableSection] = []
        @Published fileprivate(set) var selectedOption: TopUpOptionItemView.VM? = nil
    }
    
    @ObservedObject var vm: VM
    
    var body: some View {
        VStack {
            Text(vm.title)
            List(vm.availableSections, id: \.type) { section in
                Section(section.title) {
                    ForEach(section.items) { item in
                        TopUpOptionItemView(vm: item) {
                            vm.handleAction(.optionSelected(item))
                        }
                    }
                }
            }
        }
        .padding()
        .onAppear { vm.handleAction(.onAppear) }
    }
}

// Screens subviews

struct TopUpOptionItemView: SubView {
    struct VM: Identifiable {
        let id = UUID()
        let title: String
        var description: String = ""
        let image: ImageType
    }
    
    let vm: VM
    let onClicked: EmptyClosure
    
    var body: some View {
        HStack {
            Image(vm.image)
            VStack {
                Text(vm.title)
                Text(vm.description)
            }
        }
    }
}

// MARK: - UI helpers module

typealias EmptyClosure = () -> Void
typealias SubView = View

enum ImageType {
    case name(String)
    case systemName(String)
    case uiImage(UIImage)
    case data(Data)
    
    var image: Image {
        .init("todo")
    }
}

extension Image {
    init(_ imageType: ImageType) {
        self = imageType.image
    }
}
