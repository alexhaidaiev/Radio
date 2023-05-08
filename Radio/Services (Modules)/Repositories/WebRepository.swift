//
//  WebRepository.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 16.04.2023.
//

protocol APIResponse: Decodable { }

protocol WebError: Error {
    static var noInternet: Self { get }
    static var responseTimeOut: Self { get }
}

protocol WebRepository<RepositoryError>: Repository where RepositoryError: WebError {
    associatedtype RequestType
    
    func executeRequest<T: APIResponse>(for: RequestType) -> AnyRPublisher<T, RepositoryError>
}
