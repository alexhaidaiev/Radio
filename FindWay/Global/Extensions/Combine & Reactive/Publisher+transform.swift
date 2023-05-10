//
//  Publisher+transform.swift
//  FindWay
//
//  Created by Oleksandr Haidaiev on 27.03.2023.
//

import Foundation
import Combine

protocol ErrorWithUnwrapError: Error { }

extension Publisher {
    func unwrap<T, E: ErrorWithUnwrapError>(orThrow error: @escaping @autoclosure () -> E)
    -> AnyPublisher<T, E> where Self.Output == T?, Self.Failure == E {
        tryMap { value -> T in
            guard let value = value else {
                throw error()
            }
            return value
        }
        .mapError { $0 as! E }
        .eraseToAnyPublisher()
    }
    
    func delayOnMain(_ delayInSec: TimeInterval) -> AnyPublisher<Self.Output, Self.Failure> {
        return self
            .delay(for: RunLoop.SchedulerTimeType.Stride(delayInSec), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
#if DEBUG
    var fakeAPIDelay: AnyPublisher<Self.Output, Self.Failure> {
        let delay = isTesting ? GlobalConst.fakeAPIDelayForTests : GlobalConst.fakeAPIDelay
        return self
            .delayOnMain(delay)
            .eraseToAnyPublisher()
    }
#endif
}
