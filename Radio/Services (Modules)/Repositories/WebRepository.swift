//
//  WebRepository.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 16.04.2023.
//

protocol WebError: Error {
    static var noInternet: Self { get }
}

protocol APIResponse: Decodable { }

protocol WebRepository: Repository {
    associatedtype RepositoryError: WebError
    
    func executeRequest<T: APIResponse>(endpoint: RESTEndpoint) -> AnyRPublisher<T, RepositoryError>
}