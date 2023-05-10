//
//  Store.swift
//  FindWay
//
//  Created by Oleksandr Haidaiev on 29.03.2023.
//

import Foundation
import Combine

//@dynamicMemberLookup // Possible alternative way, need to test
class Store<Value> {
    var currentValue: Value { subject.value }
    
    private var subject: CurrentValueSubject<Value, Never>
    
    init(_ value: Value) {
        self.subject = CurrentValueSubject(value)
    }
    
//    subscript<T>(dynamicMember keyPath: WritableKeyPath<Value, T>) -> T {
//        get { subject.value[keyPath: keyPath] }
//        set { subject.value[keyPath: keyPath] = newValue }
//    }

//    subscript(dynamicMember _ subj: String) -> CurrentValueSubject<Value, Never> {
//        get { self.subject }
//        set { self.subject = newValue }
//    }
    
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

/* Alternative realization
typealias Store<Value> = CurrentValueSubject<Value, Never>
 
extension Store where Failure == Never {
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
