//
//  BankApp.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 12.08.2023.
//

import Foundation

// Application

struct SomeCountryTarget1 {
    private let di: DI = .debug
    private let appStore: AppStore = .init(reducer: .init())
    
    init() {
        // create and show Home screen
    }
}
struct SomeCountryTarget2 {
    // it will have some diffs in logic, data, ui, design system, etc
}

import Combine

struct AppStore {
    typealias StateSubject = CurrentValueSubject<AppState2, Never> // TODO: limit access to write only for reducer
    
    let appState: StateSubject = .init(.initialDebug)
    let reducer: AppReducer
}

struct AppState2 { // TODO: rename after moving to a separate target
    static let initialDebug: Self = .init(
        settings: .initialDebug,
        features: .initialDebug
    )
    
    struct Settings {
        static let initialDebug: Self = .init(
            isDarkMode: false, // TODO: get real values from system
            languageCode: "en"
        )
        
        var isDarkMode: Bool
        var languageCode: String
    }
    
    struct Features {
        static let initialDebug: Self = .init()
        
        var home: Home.State?
        var topUp: TopUp.State?
        var transferToCard: TransferToCard.State?
    }
    
    var settings: Settings
    var features: Features
    // authorization, config, etc
}

struct AppReducer {
    enum Action {
        // Common
        case userLoaded(user: Domain.User)
        case cardsLoaded(cards: [Domain.CardMainData])
        
        enum Home {
            // Actions
            case selectCard(id: Domain.CardId)
            case openTopUp
            case openTransferToCard
            // Events
            case initialDataLoaded(user: Domain.User,
                                   cards: [Domain.CardMainData],
                                   selectedCardId: Domain.CardId)
        }
        enum TopUp {
            case optionsLoaded([Domain.TopUp.Option])
            case optionsSelected(Domain.TopUp.Option)
        }
    }
    
    static func handleAction(_ action: Action, appState: AppStore.StateSubject) {
        switch action {
        case .userLoaded(let user):
            appState.value[keyPath: \.features.home!.user] = user // TODO: remove `!`
        default:
            break // TODO: add all
        }
    }
}

class DI {
    static let debug: DI = .init(sharedServices: .debug,
                                 vmServices: .debug)
    static let swiftUI: DI = .init(sharedServices: .swiftUI,
                                   vmServices: .swiftUI)
    
    let sharedServices: SharedServices
    let vmServices: VMServices
    // local storage, etc
    
    init(sharedServices: SharedServices,
         vmServices: VMServices) {
        self.sharedServices = sharedServices
        self.vmServices = vmServices
    }
}
extension VMServices {
    static let debug: Self = .init(localize: RealLocalizationService(),
                                   analytic: RealAnalyticService())
    static let swiftUI: Self = .init(localize: RealLocalizationService(),
                                     analytic: FakeAnalyticService())
}
extension SharedServices {
    static let debug: Self = .init(network: RealNetworkService(),
                                   navigation: RealNavigationService())
    static let swiftUI: Self = .init(network: FakeNetworkService(),
                                     navigation: RealNavigationService())
}

struct RealNetworkService: NetworkService { }
struct FakeNetworkService: NetworkService { }

struct RealNavigationService: NavigationService {
    func showScreen<T>(_ screen: T) {
        // router.show(screen)
    }
}

struct RealLocalizationService: LocalizationService {
    func text(for key: LocalizationKey) -> String {
        NSLocalizedString(key.description, comment: "") // check implementation later
    }
}
struct RealAnalyticService: AnalyticService {
    func sendEvent(_ event: AnalyticEvent) {
        print(event) // Analytics integration here
    }
}
struct FakeAnalyticService: AnalyticService {
    func sendEvent(_ event: AnalyticEvent) { }
}

// TODO: move entities to appropriate modules and files
// MARK: Features modules

class TopUpFeature {
    struct Reducer {
        
    }
    
    private var mainOperator: TopUpFeatureOperator = .init()
    
    private let di: DI
    private let store: AppStore
    private var cancellable: Set<AnyCancellable> = []
    
    init(di: DI, store: AppStore) {
        self.di = di
        self.store = store
    }
    
    func launch() {
        openStartScreen()
        
        store.appState
//            .map(\.features.topUp)
//            .replaceNil(with: <#T##T#>)
//            .removeDuplicates()
            .sink { [weak self] newState in
                if let topUpState = newState.features.topUp {
                    self?.mainOperator.rootOperator?.handleNewState(topUpState)
                }
        }
        .store(in: &cancellable)
    }
    
    func finish() {
        
    }
    
    private func openStartScreen() {
        
        let vm: TopUpRootVM = .init(vmServices: di.vmServices)
        let rootOperator: TopUpRootOperator = .init(di: di, vm: vm)
        mainOperator.rootOperator = rootOperator
        
        let screen: TopUpRootView = .init(vm: vm)
        di.sharedServices.navigation.showScreen(screen)
    }
}

class TransferToCardFeature { }
class AchievementsFeature { }

struct TopUpFeatureOperator {
    var rootOperator: TopUpRootOperator?
    var fromCardOperator: TopUpFromCardOperator?
//    let fromPaymentSystemOperator: TopUpFromCardOperator
//    let finishedOperator: TopUpFromCardOperator
}

// MARK: Core services module

protocol NetworkService {
    
}

protocol NavigationService {
    func showScreen<T>(_ screen: T)
}

struct SharedServices {
    let network: NetworkService
    let navigation: NavigationService
}

protocol AnalyticEvent {}
protocol AnalyticService {
    func sendEvent(_ event: AnalyticEvent)
}

protocol LocalizationKey: CustomStringConvertible {}
enum LocalizationFormats {
    case cardLastDigestShort(_ lastDigits: String)
}
protocol LocalizationService {
    func text(for key: LocalizationKey) -> String
    func formats(for type: LocalizationFormats) -> String
}
extension LocalizationService { // move to app targets ?
    func formats(for type: LocalizationFormats) -> String {
        switch type {
        case .cardLastDigestShort(let lastDigits):
            return "* \(lastDigits)" // localize `* ` later
        }
    }
}

//protocol ResourcesService {} // or imagesService?

struct VMServices { // split to DataServices and EventServices ?
    let localize: LocalizationService
    let analytic: AnalyticService
    // alert, snackBar, toast, etc
}

// MARK: Domain module


enum Domain {
    typealias CardId = String // replace with strong/fantom type later
    
    struct User {
        let name: String
        let surname: String
        // email, phone, birthday, etc
    }
    
    // Card related
    
    struct CardFullData { // TODO: extract to `enum Card`
        enum PhysicalType {
            case physical, digitalOnly
        }
        
        let mainInfo: CardMainData
        let privateData: CardPrivateData?
        let physicalType: PhysicalType
        let balance: Int
    }
    
    struct CardMainData {
        enum CardType {
            case credit, debit, government, child
            case otherBank
        }
        enum Currency { // move to root?
            case uah, usd, eur
        }
        
        let id: CardId
        let type: CardType
        let currency: Currency
        let lastDigits: String
        let name: String
        let customName: String?
        let isExpired: Bool
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
    
    // TopUp related
    
    enum TopUp {
        enum Option {
            case fromSavedCard, fromMyCard, fromOtherBankCard, byRequisites, byPaymentSystem
            case swift, sepa
        }
    }
}

// Top up part
// Do we need a separate module for it?

enum Home {
    struct State {
        var user: Domain.User
        var card: Domain.CardFullData
    }
}

enum TopUp { // place inside enum Feature ?
    struct State {
        struct Shared {
            var selectedCard: Domain.CardMainData
            var userCards: [Domain.CardMainData]
            var savedCards: [Domain.CardMainData]
        }
        
        var shared: Shared
        var availableOptions: [Domain.TopUp.Option]
        
        // Sub states
//        let topUpRootState: TopUpRootState
//        let topUpFromSavedCardState: TopUpFromSavedCardState
//        let topUpFromMyCardState: TopUpFromMyCardState
//        let topUpResultState: TopUpResultState
    }
    
    enum RootScreen {
        enum Localization: String, LocalizationKey {
            var description: String { rawValue } // find a better way
            // or swap it with RootScreen ?
            case sectionsTitle = "Top up current curd" // TODO: integrate `NSLocalizedString`
            case savedCardsSectionTitle = "Saved cards"
            case myCardsSectionTitle = "My cards"
            case otherSectionTitle = "Other methods"
        }
        enum Analytic: AnalyticEvent {
            case appear
            case optionSelected(Domain.TopUp.Option)
        }
    }
    enum FromSavedCardScreen {}
    enum SuccessScreen {}
}
extension AnalyticEvent where Self == TopUp.RootScreen.Analytic {
    static func topUpRoot(_ event: Self) -> Self { event }
}
extension LocalizationKey where Self == TopUp.RootScreen.Localization {
    static func topUpRoot(_ key: Self) -> Self { key }
}

enum TransferToCard {
    enum State { }
}

//extension TopUp.State {
//    struct TopUpRootState {
//        let availableOptions: [TopUp.TopUpOptions]
//    }
//}

struct TopUpRootOperator { // Interactor?
//    let sharedServices: SharedServices
    let di: DI
    let vm: TopUpRootVM
    
    func handleNewState(_ state: TopUp.State) {
        vm.handleNewState(state)
    }
}

struct TopUpFromCardOperator {
    let sharedServices: SharedServices
//    let vm: TopUpFromAnotherCardVMCommon
}

// MARK: - UI module

struct TopUpRootVMMapper: TopUpRootVMMapping {
    let localize: LocalizationService
}

/// A default realization, provide your own if needed
class TopUpRootVM: TopUpRootView.VM {
    private let vmServices: VMServices
    private let mapper: TopUpRootVMMapping
    
    init(vmServices: VMServices, mapper: TopUpRootVMMapping? = nil) {
        self.vmServices = vmServices
        self.mapper = mapper ?? TopUpRootVMMapper(localize: vmServices.localize)
    }
    
    func handleNewState(_ state: TopUp.State) {
        title = vmServices.localize.text(for: .topUpRoot(.sectionsTitle))
        availableSections = mapper.availableSectionsFrom(state)
    }
    
    override func handleAction(_ action: TopUpRootView.VM.Action) {
        switch action {
        case .onAppear:
            vmServices.analytic.sendEvent(.topUpRoot(.appear))
            // ask to load data
        case .optionSelected(let option):
            vmServices.analytic.sendEvent(.topUpRoot(.optionSelected(option.type)))
            selectedOption = option // TODO: move it from VM to Router
        }
    }
}
// TODO: add e.g `TopUpRootVMCountry2` to demonstrate customization
// e.g display the title like - "\(userNameShort), select a top up method for \(cardName) card"

protocol TopUpRootVMMapping {
    var localize: LocalizationService { get }
}

extension TopUpRootVMMapping {
    typealias AvailableSection = TopUpRootView.VM.AvailableSection
    
    func localizedText(for key: TopUp.RootScreen.Localization) -> String {
        localize.text(for: key)
    }
    
    func availableSectionsFrom(_ state: TopUp.State) -> [AvailableSection] {
        var savedCardsSection: AvailableSection = .init(
            type: .savedCards,
            title: localizedText(for: .savedCardsSectionTitle)
        )
        var myCardsSection: AvailableSection = .init(
            type: .myCards,
            title: localizedText(for: .myCardsSectionTitle)
        )
        var otherSection: AvailableSection = .init(
            type: .other,
            title: localizedText(for: .otherSectionTitle)
        )
        
        state.availableOptions.forEach { option in
            switch option {
            case .fromSavedCard:
                state.shared.savedCards.forEach {
                    savedCardsSection.items.append(
                        .init(title: $0.customName ?? $0.name,
                              description: localize.formats(
                                for: .cardLastDigestShort($0.lastDigits)
                              ),
                              image: .name("saved_card.icon"),
                              type: .fromSavedCard) // TODO: temp, revert later
                    )
                }
            case .fromMyCard:
                state.shared.userCards
                    .filter { $0.id != state.shared.selectedCard.id && !$0.isExpired}
                    .forEach {
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
    
    func myCardItemFrom(cardType: Domain.CardMainData.CardType) -> TopUpOptionItemView.VM? {
        // TODO: localize all
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
    
    func otherItemFrom(option: Domain.TopUp.Option) -> TopUpOptionItemView.VM? {
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

/// A list with available options to make a top up
// TODO: extract it to `ListWithHeaderAndSectionsStyle1View<Section>`, `SectionStyle1View<Cell>`, `SectionCellStyle1View`
// as abstract views and use them for `TopUp` and `TransferToCard` screens
struct TopUpRootView: View {
    class VM: ObservableObject {
        struct AvailableSection {
            enum SectionType { // remove it to achieve abstraction
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
        
        @Published fileprivate(set) var title: String
        @Published fileprivate(set) var availableSections: [VM.AvailableSection]
        @Published fileprivate(set) var selectedOption: TopUpOptionItemView.VM?
        
        init(title: String = "",
             availableSections: [VM.AvailableSection] = [],
             selectedOption: TopUpOptionItemView.VM? = nil) {
            self.title = title
            self.availableSections = availableSections
            self.selectedOption = selectedOption
        }
    }
    
    @ObservedObject var vm: VM
    
    var body: some View {
        VStack {
            Text(vm.title)
            List(vm.availableSections, id: \.type) { section in
                Section(section.title) {
                    ForEach(section.items) { item in
                        // TODO: try to find how to use `trailing closure` syntax for `ViewAction`
                        // TopUpOptionItemView(vm: item) {
                        TopUpOptionItemView(vm: item, onClicked: .init {
                            vm.handleAction(.optionSelected(item))
                        })
                    }
                }
            }
        }
        .padding(.top)
        .onAppear { vm.handleAction(.onAppear) }
    }
}

struct TopUpRootView_Previews: PreviewProvider {
    static var previews: some View {
        TopUpRootView(vm: .Mock.allSections)
    }
}

// Screens subviews

/// A cell that represent a top up option
struct TopUpOptionItemView: SubView {
    struct VM: Identifiable { // use Model/ModelDTO for static data ?
        let id = UUID()
        let title: String
        var description: String = ""
        let image: ImageType
        
        var type: Domain.TopUp.Option = .fromMyCard // TODO: temp solution, remove it
    }
    
    let vm: VM
    let onClicked: ViewActionEmpty
    
    var body: some View {
        HStack {
            Image(vm.image)
            VStack {
                Text(vm.title)
                Text(vm.description)
            }
        }
        .onTapGesture {
            onClicked.perform()
        }
    }
}

struct TopUpOptionItemView_Previews: PreviewProvider {
    static var previews: some View {
        TopUpOptionItemView(vm: .Mock.cardBlack,
                            onClicked: .previewsAction)
    }
}

// ViewModels mocks

extension TopUpRootView.VM {
    typealias VM = TopUpRootView.VM
    
    enum Mock {
        static let allSections: VM = .init(
            title: "¡All sections",
            availableSections: [
                .init(type: .savedCards, title: "¡Saved cards", items: [.mock.savedCard]),
                .init(type: .myCards, title: "¡My cards", items: [.mock.cardBlack, .mock.cardWhite]),
                .init(type: .other, title: "¡Other options", items: [.mock.swift, .mock.sepa])
            ]
        )
        static let myCardsAndOtherSections: VM = .init(
            title: "¡My cards + other",
            availableSections: [
                .init(type: .myCards, title: "¡My cards", items: [.mock.cardBlack, .mock.cardWhite]),
                .init(type: .other, title: "¡Other options", items: [.mock.swift])
            ]
        )
    }
}

extension TopUpOptionItemView.VM {
    typealias VM = TopUpOptionItemView.VM
    
    static let mock: Mock.Type = Mock.self
    
    enum Mock {
        static let savedCard: VM = .init(title: "¡Jong H.",
                                         description: "¡* 8061",
                                         image: someImage)
        static let cardBlack: VM = .init(title: "¡A black card", image: someImage)
        static let cardWhite: VM = .init(title: "¡A white card", image: someImage)
        static let swift: VM = .init(title: "¡A SWIFT transfer", image: someImage)
        static let sepa: VM = .init(title: "¡A SEPA transfer", image: someImage)
        
        private static let someImage: ImageType = .systemName("creditcard.fill")
    }
}

// MARK: - UI helpers module

//typealias UIAction = () -> Void
//var uiActionEmpty: UIAction { {} }

typealias SubView = View
typealias ViewActionEmpty = ViewAction<Void>

extension ViewActionEmpty {
    static var previewsAction: Self { .init {} }
    func perform() {
        action( () )
    }
}

//@dynamicMemberLookup
struct ViewAction<T> {
    typealias ClosureType<D> = (D) -> Void
    //    static func forPreviews2<D>() -> ViewAction<D> { ViewAction<D> { _ in } }
    
    let action: ClosureType<T>
    
    func perform(_ with: T) {
        action(with)
    }
//    subscript(dynamicMember unusedParameter: String = "") -> ClosureType<T> {
//        get { self.action }
//        set { self.action = newValue }
//    }
}

enum ImageType {
    case name(String)
    case systemName(String)
    case uiImage(UIImage)
    case data(Data)
    
    var image: Image {
        switch self {
        case .name(let name): return .init(name)
        case .systemName(let name): return .init(systemName: name)
        case .uiImage(let uIImage): return .init(uiImage: uIImage)
        case .data(let data): return .init(uiImage: .init(data: data) ?? .init())
        }
    }
}

extension Image {
    init(_ imageType: ImageType) {
        self = imageType.image
    }
}
