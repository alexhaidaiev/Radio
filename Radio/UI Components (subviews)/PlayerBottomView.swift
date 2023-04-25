//
//  PlayerBottomView.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 25.04.2023.
//

import SwiftUI

struct PlayerBottomView: View {
    @Environment(\.injectedDI) private var di: DIContainer
    @StateObject private var updater = ViewUpdater()
    
    private var playerDataBinding: Binding<AppState.SharedData.AudioPlayerData> {
        Binding(to: di.appState, for: \.sharedData.audioPlayerData)
    }
    private var playerData: AppState.SharedData.AudioPlayerData { playerDataBinding.wrappedValue }
    
    var body: some View {
        VStack {
            Spacer()
            
            if playerData.itemToPlay != nil {
                HStack {
                    Text(playerData.itemToPlay?.text ?? "")
                    
                    Button {
                        playerDataBinding.isPlaying.wrappedValue.toggle()
                    } label: {
                        Text(playerData.isPlaying ? "Pause" : "Play")
                            .font(.title3)
                    }
                }
                .padding()
                .background(Color.gray)
                .cornerRadius(20)
                .padding()
            }
        }
        .onReceive(di.appState.publisher(for: \.sharedData.audioPlayerData).dropFirst(),
                   perform: { _ in appStateDataChanged() } )
    }
    
    private func appStateDataChanged() {
        updater.notifyViewToRedraw()
    }
}

struct PlayerBottomView_Previews: PreviewProvider, GeneralPreview {
    static var previewsWithGeneralSetup: some View {
        PlayerBottomView()
            .onAppear {
                diForPreviews.appState[\.sharedData].audioPlayerData.itemToPlay = .fakeStation()
            }
    }
}
