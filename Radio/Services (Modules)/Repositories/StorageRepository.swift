//
//  StorageRepository.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 17.04.2023.
//

protocol StorageRepositoryGetError: Error { }

protocol StorageRepository: Repository {
    associatedtype GetOptions
    associatedtype GetError: StorageRepositoryGetError
    
    associatedtype SaveOptions
    associatedtype SaveError: Error
    
    func getData<T: Decodable>(for: GetOptions) -> AnyRPublisher<T, GetError>
    func saveData<T: Decodable>(_ data: T, options: SaveOptions) -> AnyRPublisher<Void, SaveError>
}

protocol FakeStorageRepository: StorageRepository {
    associatedtype From
    
    func getFakeData<T: Decodable>(from: From) -> AnyRPublisher<T, GetError>
}
