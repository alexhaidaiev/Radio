//
//  HomeViewModel.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 16.04.2023.
//

import Combine

protocol ActionWithScreenLoading {
    static var loadScreenData: Self { get }
}

class HomeViewModel: ObservableObject {
    enum Action: ActionWithScreenLoading {
        case onAppear
        case loadScreenData
    }
    
    @Published private(set) var mainCategories: MainCategoriesModel?
    
    let dataProvider: RealMainCategoriesDataProvider
    private var cancellable = Set<AnyCancellable>()
    
    init() {
        let baseURL = "https://opml.radiotime.com/"
        let networkRepo = RESTWebRepository(session: .init(configuration: .default),
                                            requestBuilder: URLRequestBuilder(baseURL: baseURL))
        dataProvider = RealMainCategoriesDataProvider(networkRepository: networkRepo,
                                                  storageRepository: LocalJSONRepository())
    }
    
    func handleAction(_ event: Action) {
        switch event {
        case .onAppear:
            loadScreenData()
        case .loadScreenData:
            loadScreenData()
        }
    }
    
    private func loadScreenData() {
        dataProvider
            .getDataFromAPI()
            .sink(receiveCompletion: { completion in
                print(completion)
            }, receiveValue: { [weak self] value in
                self?.mainCategories = value
            })
            .store(in: &cancellable)
    }
}
