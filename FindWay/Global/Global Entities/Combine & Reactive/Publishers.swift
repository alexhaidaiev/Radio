//
//  Publishers.swift
//  FindWay
//
//  Created by Oleksandr Haidaiev on 15.04.2023.
//

import Foundation
import Combine

#if DEBUG
struct JustWithError<Output, Failure: Error>: Publisher {
    typealias Output = Output
    typealias Failure = Failure
    
    private let output: Output
    
    init(_ output: Output) {
        self.output = output
    }
    
    func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
        Just(output)
            .setFailureType(to: Failure.self)
            .receive(subscriber: subscriber)
    }
}
#endif
