//
//  Loadable.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 22.04.2023.
//

enum Loadable<T, E: Error> {
    case readyToStart
    case loadingInProgress(_ previous: T?, _ cancellable: AnyCancellableSet)
    case loadedSuccess(T)
    case loadedFailed(E)
    
    var data: T? {
        switch self {
        case .loadedSuccess(let data): return data
        case .loadingInProgress(let previous, _): return previous
        default: return nil
        }
    }
    var isLoading: Bool {
        if case .loadingInProgress = self { return true }
        return false
    }
}
