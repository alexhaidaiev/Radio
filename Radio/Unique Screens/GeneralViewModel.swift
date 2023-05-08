//
//  GeneralViewModel.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 22.04.2023.
//

typealias GeneralViewModel = ViewModelWithActionHandling & ViewModelWithLoadingContent

protocol BaseViewModel {}

protocol ViewModelWithActionHandling: BaseViewModel {
    associatedtype A: VMAction
    func handleAction(_ action: A)
}

protocol ViewModelWithLoadingContent: BaseViewModel {}

// MARK: - Actions related

protocol VMAction {}

protocol ActionWithScreenLoading: VMAction {
    static var loadScreenData: Self { get }
}
