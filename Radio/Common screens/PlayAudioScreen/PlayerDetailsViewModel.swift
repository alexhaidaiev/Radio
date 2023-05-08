//
//  PlayerDetailsViewModel.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 23.04.2023.
//

import Foundation
import Combine

class PlayerDetailsViewModel: ObservableObject, GeneralViewModel {
    enum Action: VMAction {
        case onAppear, onDisappear
        case playPause
        case download
    }
    
    enum DownloadUIState {
        case unavailable
        case alreadyDownloaded
        case downloadState(Loadable<DownloadRepository.DownloadState,
                           DownloadRepository.RepositoryError>)
    }
    
    let audioItem:  Model.SearchDataAudioItem
    
    @Published private(set) var isPlaying = false
    @Published private(set) var downloadUIState: DownloadUIState // TODO: update UI with it
    
    private let di: DIContainer
    private let offlineMediaFilesDP: any OfflineMediaFilesDataProviding
    private var cancellable = AnyCancellableSet()
    
    init(audioItem: Model.SearchDataAudioItem,
         di: DIContainer,
         offlineMediaFilesDP: (any OfflineMediaFilesDataProviding)? = nil) {
        self.audioItem = audioItem
        self.di = di
        self.offlineMediaFilesDP = offlineMediaFilesDP ??
        di.dataProvidersFactory.createOfflineMediaFilesDP()

        if "audioItem.downloadAvailable".count > 3, let url = audioItem.url { // emulation
            if self.offlineMediaFilesDP.isFileDownloaded(for: url) {
                downloadUIState = .alreadyDownloaded
            } else {
                downloadUIState = .downloadState(.readyToStart)
            }
        } else {
            downloadUIState = .unavailable
        }
        
        di.appState
            .publisher(for: \.sharedData.audioPlayerData)
            .sink { [weak self] newPlayerData in
                self?.checkPlayingState(for: newPlayerData)
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
            guard let url = audioItem.url else { return }
            download(url: url)
        }
    }
    
    private func checkPlayingState(for playerData: AppState.SharedData.AudioPlayerData) {
        if playerData.itemToPlay?.url == audioItem.url {
            isPlaying = playerData.isPlaying
        } else {
            isPlaying = false
        }
    }
    
    private func download(url: URL) {
        let container = CancellableContainer()
        downloadUIState = .downloadState(.loadingInProgress(nil, container))
        
        offlineMediaFilesDP
            .downloadFile(for: url)
            .sinkWithLoadable { [weak self] newValue in
                self?.downloadUIState = .downloadState(newValue)
            }
            .store(in: &container.cancellable)
    }
}
