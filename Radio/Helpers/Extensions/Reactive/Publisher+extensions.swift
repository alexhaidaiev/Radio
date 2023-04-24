//
//  Publisher+extensions.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 24.04.2023.
//

import Combine
import Foundation

extension Publisher {
    func delayOnMain(_ delayInSec: TimeInterval) -> AnyPublisher<Self.Output, Self.Failure> {
        return self
            .delay(for: RunLoop.SchedulerTimeType.Stride(delayInSec), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
