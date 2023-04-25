//
//  HomeScreen.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 16.04.2023.
//

import SwiftUI

struct HomeScreen: View {
    @ObservedObject var vm: HomeViewModel
    
    @Environment(\.injectedDI) private var diContainer: DIContainer
    
    var body: some View {
        NavigationView {
            content()
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Audio topics")
                .onAppear { vm.handleAction(.onAppear) }
        }
    }
    
    @ViewBuilder
    private func content() -> some View { // TODO: create a protocol helper
        switch vm.mainCategories {
        case .readyToStart: LoadingReadyToStartView()
        case .loadingInProgress: LoadingInProgressView()
        case .loadedSuccess(let searchResults): content(for: searchResults)
        case .loadedFailed(let error): LoadingFailedView(error: error)
        }
    }
    
    private func content(for mainCategories: Model.MainCategories) -> some View {
        VStack {
            ForEach(mainCategories.categories) { mainCategory in
                if let url = mainCategory.url {
                    // TODO: move navigation logic to a Coordinator/Router, etc
                    NavigationLink(mainCategory.text) {
                        SearchResultsScreen(viewModel: .init(urlToSearch: url,
                                                             di: diContainer))
                    }
                } else {
                    EmptyView()
                }
            }
            .navigationTitle(mainCategories.title)
        }
    }
}

struct HomeScreen_Previews: PreviewProvider, GeneralPreview {
    static var previewsWithGeneralSetup: some View {
        HomeScreen(viewModel: HomeViewModel(di: diForPreviews))
    }
}
