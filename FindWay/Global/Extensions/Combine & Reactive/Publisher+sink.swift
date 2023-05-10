//
//  Publisher+sink.swift
//  FindWay
//
//  Created by Oleksandr Haidaiev on 24.03.2023.
//

import Foundation
import Combine

extension Publisher {
    func sinkWithResult(_ result: @escaping (Result<Output, Failure>) -> Void) -> AnyCancellable {
        return sink(
            receiveCompletion: { completion in
                switch completion {
                case .failure(let error): result(.failure(error))
                case .finished: break
                }
            },
            receiveValue: { value in
                result(.success(value))
            })
    }
    
    func sinkWithLoadable(_ completion: @escaping (Loadable<Output, Failure>) -> Void) -> AnyCancellable {
        return sinkWithResult { result in
            switch result {
            case .failure(let error):
                completion(.failed(error))
            case .success(let output):
                completion(.loaded(output))
            }
        }
    }
}
