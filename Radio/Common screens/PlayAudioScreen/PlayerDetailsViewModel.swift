//
//  PlayerDetailsViewModel.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 23.04.2023.
//

import Combine

class PlayerDetailsViewModel: ObservableObject, GeneralViewModel {
    enum Action: VMAction {
        case onAppear, onDisappear
        case playPause
        case download
    }
    
    let audioItem:  Model.SearchDataAudioItem
    
    @Published private(set) var isPlaying = false
        
    private let di: DIContainer
    private var cancellable = AnyCancellableSet()
    
    init(audioItem: Model.SearchDataAudioItem, di: DIContainer) {
        self.audioItem = audioItem
        self.di = di

        di.appState
            .publisher(for: \.sharedData.audioPlayerData)
            .sink { [weak self] newPlayerData in
                self?.checkState(for: newPlayerData)
            }
            .store(in: &cancellable)
    }
    
    func handleAction(_ action: Action) {
        switch action {
        case .onAppear:
            break
        case .onDisappear:
            break
        case .playPause:
            if di.appState[\.sharedData].audioPlayerData.itemToPlay != audioItem {
                di.appState[\.sharedData].audioPlayerData.itemToPlay = audioItem
                di.appState[\.sharedData].audioPlayerData.isPlaying = true
            } else {
                di.appState[\.sharedData].audioPlayerData.isPlaying.toggle()
            }
        case .download:
            break
        }
    }
    
    private func checkState(for playerData: AppState.SharedData.AudioPlayerData) {
        if playerData.itemToPlay?.url == audioItem.url {
            isPlaying = playerData.isPlaying
        } else {
            isPlaying = false
        }
    }
}
