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
        case categorySelected(Model.MainCategory)
    }
    
    @Published private(set) var mainCategories:
    Loadable<Model.MainCategories, MainCategoriesDPNetworkError> = .readyToStart

    private let diContainer: DIContainer
    private let dataProvider: any MainCategoriesDataProviding    
    private var cancellable = AnyCancellableSet()
    
    init(di: DIContainer, dataProvider: (any MainCategoriesDataProviding)? = nil) {
        self.diContainer = di
        self.dataProvider = dataProvider ?? di.dataProviderFactory.createMainCategoriesDP()
    }
    
    func handleAction(_ action: Action) {
        switch action {
        case .onAppear:
            if mainCategories == .readyToStart {
                loadScreenData()
            }
        case .loadScreenData:
            loadScreenData()
        case .categorySelected(let category):
            break
        }
    }
    
    // MARK: Private
    
    private func loadScreenData() {
        dataProvider
            .getDataFromAPI()
            .sinkWithLoadable { [weak self] new in
                self?.mainCategories = new
            }
            .store(in: &cancellable)
    }
}
