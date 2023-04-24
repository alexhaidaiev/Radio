//
//  Store.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 21.04.2023.
//

import Combine

class Store<Value> {
    var currentValue: Value { subject.value }
    
    private var subject: CurrentValueSubject<Value, Never>
    
    init(_ value: Value) {
        self.subject = CurrentValueSubject(value)
    }

    subscript<SubValue>(keyPath: WritableKeyPath<Value, SubValue>) -> SubValue
    where SubValue: Equatable {
        get { subject.value[keyPath: keyPath] }
        set {
            if subject.value[keyPath: keyPath] != newValue {
                subject.value[keyPath: keyPath] = newValue
            }
        }
    }
    
    func publisher<SubValue>(for keyPath: KeyPath<Value, SubValue>) -> AnyPublisher<SubValue, Never>
    where SubValue: Equatable {
        return subject.map(keyPath).removeDuplicates().eraseToAnyPublisher()
    }
}

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

/* Alternative realization

typealias Store2<Value> = CurrentValueSubject<Value, Never>

extension Store2 where Failure == Never {
    subscript<SubValue>(keyPath: WritableKeyPath<Output, SubValue>) -> SubValue
    where SubValue: Equatable {
        get { value[keyPath: keyPath] }
        set {
            if value[keyPath: keyPath] != newValue {
                value[keyPath: keyPath] = newValue
            }
        }
    }
    
    func publisher<SubValue>(for keyPath: KeyPath<Output, SubValue>) -> AnyPublisher<SubValue, Never>
    where SubValue: Equatable {
        return map(keyPath).removeDuplicates().eraseToAnyPublisher()
    }
}
*/

/* Possible alternative way, need to test

@dynamicMemberLookup
class Store3<Value> {
    var currentValue: Value { subject.value }
    
    private var subject: CurrentValueSubject<Value, Never>
    
    init(_ value: Value) {
        self.subject = CurrentValueSubject(value)
    }
    
    subscript<T>(dynamicMember keyPath: WritableKeyPath<Value, T>) -> T {
        get { subject.value[keyPath: keyPath] }
        set { subject.value[keyPath: keyPath] = newValue }
    }
    
    subscript(dynamicMember subj: String) -> CurrentValueSubject<Value, Never> {
        get { self.subject }
        set { self.subject = newValue }
    }
}
*/
