//
//  PlayAudioView.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 23.04.2023.
//

import SwiftUI

struct PlayAudioView: View {
    let audioItem:  Model.SearchDataAudioItem
    
    var body: some View {
        VStack {
            Text("Play")
            Text(audioItem.text)
            Text(audioItem.url?.absoluteString ?? "")
        }
    }
}

struct PlayAudioView_Previews: PreviewProvider, GeneralPreview {
    static var previewsWithGeneralSetup: some View {
        PlayAudioView(audioItem: .fakeStation(index: 1))
    }
}
