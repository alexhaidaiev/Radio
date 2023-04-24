//
//  SearchResultsLinkItemView.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 22.04.2023.
//

import SwiftUI

struct SearchResultLinkItemView: View {
    let data: Model.SearchDataLinkItem
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

struct SearchResultLinkItemView_Previews: PreviewProvider, GeneralPreview {
    static var previewsWithGeneralSetup: some View {
        SearchResultLinkItemView(data: .fakeSportCategory(index: 1), selection: { })
    }
}
