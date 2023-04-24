//
//  SearchResultsSectionView.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 22.04.2023.
//

import SwiftUI

struct SearchResultsSectionView: View {
    let data: Model.SearchData.Section
    let selection: (any ModelSearchDataItem) -> Void
    
    var body: some View {
        VStack{
            Text(data.text)
                .font(.title2)
                .padding()
            
            ForEach(data.items, id: \.id) { searchItem in
                switch searchItem {
                case let audioItem as Model.SearchDataAudioItem:
                    SearchResultAudioItemView(data: audioItem) {
                        selection(audioItem)
                    }
                case let audioItem as Model.SearchDataLinkItem:
                    SearchResultLinkItemView(data: audioItem) {
                        selection(audioItem)
                    }
                default:
                    EmptyView()
                }
            }
        }
        .padding(.bottom, 8)
    }
}

struct SearchResultsSectionView_Previews: PreviewProvider, GeneralPreview {
    static var previewsWithGeneralSetup: some View {
        VStack {
            SearchResultsSectionView(data: .fakeSectionWithRadioAudioItems, selection: { _ in })
            SearchResultsSectionView(data: .fakeSectionWithSportLinkItems, selection: { _ in })
        }
    }
}
