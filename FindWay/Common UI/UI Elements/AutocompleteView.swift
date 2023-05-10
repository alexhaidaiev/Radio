//
//  AutocompleteView.swift
//  FindWay
//
//  Created by Oleksandr Haidaiev on 27.03.2023.
//

import SwiftUI

struct AutocompleteView: View {
    @Binding var forText: String
    let cities: [City]
    let onSelect: (City) -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var filteredCities: [City] = []
    
    private var isFullMatch: Bool { filteredCities.count == 1 && filteredCities[0] == forText }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !isFullMatch {
                ForEach(filteredCities) { city in
                    Button(action: {
                        withAnimation {
                            onSelect(city)
                        }
                    }, label: {
                        Text(city)
                            .foregroundColor(.primary)
                            .padding()
                    })
                }
            }
        }
        .background(colorScheme == .dark ? Color.gray : .white)
        .cornerRadius(8)
        .shadow(radius: 8)
        .transition(.move(edge: .top))
        .animation(.easeInOut(duration: 0.3), value: filteredCities)
        .onAppear { calculateFilteredCities() }
        .onChange(of: forText) { _ in calculateFilteredCities() }
    }
    
    private func calculateFilteredCities() {
        filteredCities = cities.filter { $0.lowercased().contains(forText.lowercased()) }
    }
}


struct AutocompleteView_Previews: PreviewProvider, PreviewProviderWrapper {
    static var previewsWrap: some View {
        previewWithBinding(initialValue: "lo") { isShowPopup in
            ZStack {
                TextField("", text: isShowPopup)
                    .commonModifier()
                    .padding()
                AutocompleteView(forText: isShowPopup,
                                 cities: ["London", "Tokyo", "Los Angeles", "Los Angeles 2"],
                                 onSelect: { text in isShowPopup.wrappedValue = text })
                .offset(y: 120)
            }
        }
    }
}
