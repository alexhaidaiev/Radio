//
//  FindWayView.swift
//  FindWay
//
//  Created by Oleksandr Haidaiev on 23.03.2023.
//

import SwiftUI

struct FindWayView: View {
    private enum R: TextResources {
        enum Text: String {
            case navigationTitle = "Find best way"
            case textFieldFromPlaceholder = "Department city"
            case textFieldToPlaceholder = "Destination city"
            case buttonFindTripTitle = "Find trip"
            case buttonShowMapTitle = "Show Map"
            case buttonReloadTitle = "Reload data"
        }
        enum Image: String {
            case systemArrow = "arrow.down"
        }
    }
    
    @ObservedObject var viewModel: FindWayViewModel
    
    @State private var isShowAutocompleteFromCity = true
    @State private var isShowAutocompleteToCity = true
    @State private var isShowMap = false
    
    var body: some View {
        NavigationView {
            VStack {
                textFieldsSection
                buttonsSection
                Text(viewModel.descriptionField)
                    .font(.headline)
                    .padding()
                if viewModel.isLoading {
                    ProgressView()
                }
                Spacer()
            }
            .navigationTitle(R.text(.navigationTitle))
        }
        .onAppear { viewModel.handleAction(.onAppear) }
    }
    
    // MARK: Sub views
    
    private var textFieldsSection: some View {
        VStack {
            textFieldFrom
            .overlay(autocompleteFrom)
            .zIndex(6)
            
            Image(systemName: R.Image.systemArrow.rawValue)
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(.gray)
                .padding(6)
            
            textFieldTo
            .overlay(autocompleteTo)
            .zIndex(5)
        }
        .padding()
        .zIndex(10)
    }
    
    private var textFieldFrom: some View {
        TextField(R.text(.textFieldFromPlaceholder),
                  text: $viewModel.fromCity,
                  onEditingChanged: { isEditing in
            if isEditing {
                viewModel.handleAction(.fromCityChanged)
            }
            isShowAutocompleteFromCity = isEditing
        }, onCommit: {
            viewModel.handleAction(.showPossibleTrips)
        })
        .commonModifier()
        .disabled(viewModel.isLoading)
    }
    
    private var textFieldTo: some View {
        TextField(R.text(.textFieldToPlaceholder),
                  text: $viewModel.toCity,
                  onEditingChanged: { isEditing in
            if isEditing {
                viewModel.handleAction(.toCityChanged)
            }
            isShowAutocompleteToCity = isEditing
        }, onCommit: {
            viewModel.handleAction(.showPossibleTrips)
        })
        .commonModifier()
        .disabled(viewModel.isLoading)
    }
    
    private var autocompleteFrom: some View {
        GeometryReader { proxy in
            if isShowAutocompleteFromCity {
                AutocompleteView(
                    forText: $viewModel.fromCity,
                    cities: viewModel.allAvailableFromCities,
                    onSelect: { selectedCity in
                        viewModel.fromCity = selectedCity
                    }
                )
                .padding(.horizontal, 6)
                .offset(y: proxy.size.height + 6)
            }
        }
    }
    
    private var autocompleteTo: some View {
        GeometryReader { proxy in
            if isShowAutocompleteToCity {
                AutocompleteView(
                    forText: $viewModel.toCity,
                    cities: viewModel.allAvailableToCities,
                    onSelect: { selectedCity in
                        viewModel.toCity = selectedCity
                    }
                )
                .padding(.horizontal, 6)
                .offset(y: proxy.size.height + 6)
            }
        }
    }
    
    private var buttonsSection: some View {
        VStack(spacing: 20) {
            HStack() {
                Button(action: { viewModel.handleAction(.showPossibleTrips) }) {
                    Text(R.text(.buttonFindTripTitle))
                        .frame(maxWidth: .infinity)
                }
                .commonModifier(.mainAction(isEnabled: !viewModel.isLoading))
                .disabled(viewModel.isLoading)
                
                Button(action: { isShowMap = true }) {
                    Text(R.text(.buttonShowMapTitle))
                        .frame(maxWidth: .infinity)
                }
                .commonModifier(.mainAction(isEnabled: viewModel.isShowTripAvailable))
                .disabled(!viewModel.isShowTripAvailable)
                
                if let trip = viewModel.bestTrip {
                    // TODO: update to iOS 16
                    NavigationLink(destination: MapView(trip: trip),
                                   isActive: $isShowMap) {
                        EmptyView()
                    }
                }
            }
            Button(action: { viewModel.handleAction(.loadData) }) {
                Text(R.text(.buttonReloadTitle))
                    .frame(maxWidth: .infinity)
            }
            .commonModifier(.secondaryAction(isEnabled: !viewModel.isLoading))
            .disabled(viewModel.isLoading)
        }
        .padding()
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider, PreviewProviderWrapper {
    static var previewsWrap: some View {
        FindWayView(viewModel: .init(fromCity: "lo",
                                     toCity: "",
                                     diContainer: defaultDIForPreviews))
    }
}
