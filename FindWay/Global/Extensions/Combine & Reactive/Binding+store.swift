//
//  Binding+store.swift
//  FindWay
//
//  Created by Oleksandr Haidaiev on 02.04.2023.
//

import SwiftUI

extension Binding where Value: Equatable {
    init<T>(to store: Store<T>, for keyPath: WritableKeyPath<T, Value>) {
        self = .init(
            get: { store[keyPath] },
            set: { new in
                if store[keyPath] != new {
                    store[keyPath] = new
                }
            })
    }
}
