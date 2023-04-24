//
//  SearchResultsAudioItemView.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 23.04.2023.
//

import SwiftUI

struct SearchResultAudioItemView: View {
    let data: Model.SearchDataAudioItem
    let selection: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Button(data.text) {
                selection()
            }
            .foregroundColor(Color.blue)
            if let text = data.subtext {
                Text(text)
                    .font(.caption)
            }
        }
    }
}

struct SearchResultAudioItemView_Previews: PreviewProvider, GeneralPreview {
    static var previewsWithGeneralSetup: some View {
        VStack {
            SearchResultAudioItemView(data: .fakeStation(index: 1), selection: { })
            SearchResultAudioItemView(data: .fakeTopic(index: 1), selection: { })
        }
    }
}
