//
//  Loadable+support.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 22.04.2023.
//

import Combine

typealias AnyCancellableSet = Set<AnyCancellable>

extension Loadable: Equatable where T: Equatable {
    static func == (lhs: Loadable<T, E>, rhs: Loadable<T, E>) -> Bool {
        switch (lhs, rhs) {
        case (.readyToStart, .readyToStart):
            return true
        case (.loadingInProgress(let lhsV, _), .loadingInProgress(let rhsV, _)):
            return lhsV == rhsV
        case (.loadedSuccess(let lhsV), .loadedSuccess(let rhsV)):
            return lhsV == rhsV
        case (.loadedFailed(let lhsE), .loadedFailed(let rhsE)):
            return lhsE.localizedDescription == rhsE.localizedDescription
        default:
            return false
        }
    }
}

extension Publisher {
    func sinkWithLoadable(_ loadableUpdate: @escaping (Loadable<Output, Failure>) -> Void)
    -> AnyCancellable {
        return sink(
            receiveCompletion: { completion in
                switch completion {
                case .failure(let error): loadableUpdate(.loadedFailed(error))
                case .finished: break
                }
            },
            receiveValue: { value in
                loadableUpdate(.loadedSuccess(value))
            })
    }
}
