//
//  PlayerDetailsScreen.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 23.04.2023.
//

import SwiftUI

struct PlayerDetailsScreen: View {
    @ObservedObject var vm: PlayerDetailsViewModel
    
    var body: some View {
        VStack(spacing: 10) {
            Button {
                vm.handleAction(.playPause)
            } label: {
                Text(vm.isPlaying ? "Pause" : "Play")
                    .font(.title)
            }
            
            Text(vm.audioItem.text)
            Text(vm.audioItem.url?.absoluteString ?? "")

            Button {
                vm.handleAction(.download)
            } label: {
                Text("Download")
                    .font(.title3)
            }

        }
        .padding(4)
        .onAppear { vm.handleAction(.onAppear) }
        .onDisappear { vm.handleAction(.onDisappear) }
    }
}

struct PlayAudioView_Previews: PreviewProvider, GeneralPreview {
    static var previewsWithGeneralSetup: some View {
        PlayerDetailsScreen(vm: .init(audioItem: .fakeStation(), di: diForPreviews))
    }
}
