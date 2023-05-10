//
//  Loadable.swift
//  FindWay
//
//  Created by Oleksandr Haidaiev on 24.03.2023.
//

import Foundation
import Combine

enum Loadable<T, E: Error> {
    case notStarted
    case isLoading(_ previous: T?, _ cancellable: CancellableContainer)
    case loaded(T)
    case failed(E)

    var data: T? {
        switch self {
        case .loaded(let data): return data
        case .isLoading(let previous, _): return previous
        default: return nil
        }
    }
    var isLoading: Bool {
        if case .isLoading = self { return true }
        return false
    }
}

class CancellableContainer {
    fileprivate(set) var set = Set<AnyCancellable>()
    
    func cancel() { set.removeAll() }
}
extension AnyCancellable {
    func store(in container: CancellableContainer) {
        container.set.insert(self)
    }
}

extension Loadable: Equatable where T: Equatable {
    static func == (lhs: Loadable<T, E>, rhs: Loadable<T, E>) -> Bool {
        switch (lhs, rhs) {
        case (.notStarted, .notStarted):
            return true
        case (.isLoading(let lhsV, _), .isLoading(let rhsV, _)):
            return lhsV == rhsV
        case (.loaded(let lhsV), .loaded(let rhsV)):
            return lhsV == rhsV
        case (.failed(let lhsE), .failed(let rhsE)):
            return lhsE.localizedDescription == rhsE.localizedDescription
        default:
            return false
        }
    }
}
