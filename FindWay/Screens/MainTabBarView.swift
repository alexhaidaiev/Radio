//
//  MainTabBarView.swift
//  FindWay
//
//  Created by Oleksandr Haidaiev on 23.08.2023.
//

import SwiftUI

struct MainTabBarView: View {
    @Environment(\.injectedDI) private var diContainer: DIContainer
    
    @AppStorage("LastTabBarTab") fileprivate var selection = 0
    
    var body: some View {
        TabView(selection: $selection) {
            Group {
                FindWayView(viewModel: .init(diContainer: diContainer))
                    .tabItem {
                        Label("Find way", systemImage: "magnifyingglass.circle.fill")
                    }
                    .tag(0)
                NumberActivationView(vm: .Mock.main)
                    .tabItem {
                        Label("Number activation", systemImage: "phone.circle.fill")
                    }
                    .tag(1)
            }
            .toolbar(.visible, for: .tabBar)
            .toolbarBackground(Color.gray.opacity(0.1), for: .tabBar)
        }
    }
}

struct MainTabBarView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabBarView(selection: 1)
    }
}

fileprivate extension MainTabBarView {
    init(selection: Int) {
        self.init()
        self.selection = selection
    }
}
