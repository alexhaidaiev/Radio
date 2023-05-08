//
//  RepositoryGeneral.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 17.04.2023.
//

import Combine

// TODO: investigate - rename to GetRepository and introduce GetSetRepository
protocol Repository<RepositoryError> {
    typealias AnyRPublisher = Combine.AnyPublisher
    
    associatedtype RepositoryError: Error = Never
    // TODO: check and apply these if necessary
//    associatedtype RepositoryRequest = Void
//    associatedtype RepositoryResponse
//    associatedtype RepositoryError: Error = Never
    
}

// TODO: check and apply these if necessary
protocol SyncRepository: Repository { }
protocol AsyncRepository: Repository { }
protocol SyncStorageRepository: SyncRepository { }
protocol AsyncStorageRepository: AsyncRepository { }
