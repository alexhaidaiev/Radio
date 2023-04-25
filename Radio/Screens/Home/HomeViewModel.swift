//
//  HomeViewModel.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 16.04.2023.
//

import Combine

class HomeViewModel: ObservableObject, GeneralViewModel {
    enum Action: ActionWithScreenLoading {
        case onAppear
        case loadScreenData
    }
    
    @Published private(set) var mainCategories:
    Loadable<Model.MainCategories, MainCategoriesDPNetworkError> = .readyToStart

    private let diContainer: DIContainer
    private let mainCategoriesDataProvider: any MainCategoriesDataProviding    
    private var cancellable = AnyCancellableSet()
    
    init(di: DIContainer, dataProvider: (any MainCategoriesDataProviding)? = nil) {
        self.diContainer = di
        self.mainCategoriesDataProvider = dataProvider
        ?? di.dataProvidersFactory.createMainCategoriesDP()
    }
    
    func handleAction(_ action: Action) {
        switch action {
        case .onAppear:
            if mainCategories == .readyToStart {
                loadScreenData()
            }
        case .loadScreenData:
            loadScreenData()
        }
    }
    
    // MARK: Private
    
    private func loadScreenData() {
        mainCategoriesDataProvider
            .getCategoriesFromAPI()
            .sinkWithLoadable { [weak self] new in
                self?.mainCategories = new
            }
            .store(in: &cancellable)
    }
}
