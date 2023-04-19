//
//  HomeView.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 16.04.2023.
//

import SwiftUI

struct HomeScreen: View {
    
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                ForEach(viewModel.mainCategories?.sources ?? []) { element in
                    Text(element.text)
                }
            }
            .navigationTitle("Audio topics")
        }
        .onAppear { viewModel.handleAction(.onAppear) }
    }
}
