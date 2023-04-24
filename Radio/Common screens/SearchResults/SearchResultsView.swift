//
//  SearchResultsView.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 22.04.2023.
//

import SwiftUI

struct SearchResultsScreen: View {
    @ObservedObject var viewModel: SearchResultsViewModel

    @Environment(\.injectedDI) private var diContainer: DIContainer
    
    var body: some View {
        content()
            .onAppear { viewModel.handleAction(.onAppear) }
            .navigationDestination(for: $viewModel.selectedItem) { item in
                if item.type == .audio, let audioItem = item as? Model.SearchDataAudioItem {
                    PlayAudioView(audioItem: audioItem)
                } else if let url = item.url {
                    SearchResultsScreen(viewModel: .init(urlToSearch: url, di: diContainer))
                }
            }
    }

    @ViewBuilder
    private func content() -> some View {
        switch viewModel.searchResults {
        case .readyToStart: LoadingReadyToStartView()
        case .loadingInProgress: LoadingInProgressView()
        case .loadedSuccess(let searchResults): content(for: searchResults)
        case .loadedFailed(let error): LoadingFailedView(error: error)
        }
    }
    
    private func content(for searchResult: Model.SearchData) -> some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(searchResult.listOfAudioItems) { item in
                    SearchResultAudioItemView(data: item) {
                        viewModel.handleAction(.shouldSelect(item: item))
                    }
                }
                ForEach(searchResult.listOfLinkItems) { item in
                    SearchResultLinkItemView(data: item) {
                        viewModel.handleAction(.shouldSelect(item: item))
                    }
                }
                
                ForEach(searchResult.sectionsWithLists) { section in
                    SearchResultsSectionView(data: section) { selectedItem in
                        viewModel.handleAction(.shouldSelect(item: selectedItem))
                    }
                    .padding()
                }
            }
            .frame(maxWidth: .infinity)
            .navigationTitle(searchResult.title)
        }
    }
}

struct SearchResultsViewModel_Previews: PreviewProvider, GeneralPreview {
    static var placeInNavigation: Bool { true }
    static var previewsWithGeneralSetup: some View {
        let vm = SearchResultsViewModel(urlToSearch: .forDebug(.musicWorldMix),
                                        di: diForPreviews)
        SearchResultsScreen(viewModel: vm)
    }    
}
