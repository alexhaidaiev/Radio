//
//  AudioManager.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 25.04.2023.
//

import AVFoundation
import Combine

class AudioManager { // rename to MediaManager ?? and move to the folder
    private lazy var player = AVPlayer()
    
    private let appState: Store<AppState>
    private var cancellable = AnyCancellableSet()

    init(appState: Store<AppState>) {
        self.appState = appState
        
        appState
            .publisher(for: \.sharedData.audioPlayerData)
            .sink { [weak self] playerData in
                if let url = playerData.itemToPlay?.url, playerData.isPlaying {
                    self?.play(url: url)
                } else {
                    self?.pause()
                }
            }
            .store(in: &cancellable)
    }
    
    private func play(url: URL) {
        player.replaceCurrentItem(with: AVPlayerItem(url: url))
        player.play()
    }
    
    private func pause() {
        player.pause()
    }
}
