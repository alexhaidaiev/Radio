//
//  SearchResultsViewModel.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 20.04.2023.
//

import Foundation
import Combine

class SearchResultsViewModel: ObservableObject, GeneralViewModel {
    enum Action: ActionWithScreenLoading {
        case onAppear
        case loadScreenData
        case shouldSelect(item: any ModelSearchDataItem)
    }
    
    @Published var selectedItem: (any ModelSearchDataItem)?
    @Published private(set) var searchResults:
    Loadable<Model.SearchData, SearchDPNetworkError> = .readyToStart
    
    let urlToSearch: URL
    private let diContainer: DIContainer
    private let searchDataProvider: any SearchDataProviding
    private var cancellable = AnyCancellableSet()
    
    init(urlToSearch: URL,
         di: DIContainer,
         searchDataProvider: (any SearchDataProviding)? = nil) {
        self.urlToSearch = urlToSearch
        self.diContainer = di
        self.searchDataProvider = searchDataProvider ?? di.dataProviderFactory.createSearchDP()
    }
    
    func handleAction(_ action: Action) {
        switch action {
        case .onAppear:
            if searchResults == .readyToStart {
                loadScreenData()
            }
        case .loadScreenData:
            loadScreenData()
        case .shouldSelect(item: let item):
            selectedItem = item
        }
    }
    
    // MARK: Private
    
    private func loadScreenData() {
        searchDataProvider
            .searchUsing(url: urlToSearch)
            .sinkWithLoadable { [weak self] new in
                self?.searchResults = new
            }
            .store(in: &cancellable)
    }
}
