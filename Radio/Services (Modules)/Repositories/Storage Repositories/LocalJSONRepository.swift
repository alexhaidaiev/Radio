//
//  LocalJSONRepository.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 17.04.2023.
//

import Foundation
import Combine

struct LocalJSONRepository: StorageRepository {    
    struct RequestParameters {
        let fileName: String
        let fileSubdirectory: String?
    }
    enum RepositoryError: StorageRepositoryGetError {
        case fileNotFound(String)
        case decodingFailed(Error)
    }
    
    struct SaveOptions {
        let fileName: String
        let path: String
    }
    enum SaveError: Error {
        case cantSave
    }
    
    func getData<T: Decodable>(for request: RequestParameters) -> AnyPublisher<T, RepositoryError> {
        Result { try Self.loadJSONFromBundle(name: request.fileName, in: request.fileSubdirectory) }
        .publisher
        .mapError { $0 as! RepositoryError }
        .eraseToAnyPublisher()
    }
    
    func saveData<T: Decodable>(_ data: T, options: SaveOptions) -> AnyPublisher<Void, SaveError> {
        assertionFailure("Not implemented yet")
        return Fail<Void, LocalJSONRepository.SaveError>(error: SaveError.cantSave)
            .eraseToAnyPublisher()
    }
    
    static func loadJSONFromBundle<T: Decodable>(name: String,
                                                 in subdirectory: String? = nil) throws -> T {
        guard let url = Bundle.main.url(forResource: name,
                                        withExtension: "json",
                                        subdirectory: subdirectory) else {
            throw RepositoryError.fileNotFound(name)
        }
        do {
            let data = try Data(contentsOf: url)
            let entity = try JSONDecoder().decode(T.self, from: data)
            return entity
        } catch let error {
            throw RepositoryError.decodingFailed(error)
        }
    }
}
