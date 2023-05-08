//
//  DownloadRepository.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 26.04.2023.
//

import Foundation
import Combine

enum DownloadWebError: WebError {
    case noInternet
    case responseTimeOut
    case incorrectURL
    case unexpectedResponse
    case storageError(_ error: Error)
    case urlError(_ error: URLError)
}

struct DownloadRepository: Repository {
    typealias RepositoryError = DownloadWebError
    
    enum DownloadState: Equatable {
        /// `percent` is a value in the range [0...1]
        case inProgress(percent: Double)
        case finished(targetFileLocation: URL)
    }
    
    let session: URLSession
    
    /// Use it for small files
    func downloadToMemory(url: URL) -> AnyPublisher<Data?, Never> {
        session.dataTaskPublisher(for: url)
            .map { $0.data }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
    
    func downloadToDisk(url: URL, to targetLocation: URL) -> AnyPublisher<URL, DownloadWebError> {
        let downloadPublisher = Future<URL, URLError> { promise in
            let task = session.downloadTask(with: url) { tempLocation, response, error in
                if let urlError = error as? URLError {
                    promise(.failure(urlError))
                    return
                }
                guard let response = response as? HTTPURLResponse,
                      (200..<300) ~= response.statusCode else {
                    promise(.failure(URLError(.badServerResponse)))
                    return
                }
                guard let tempLocation = tempLocation else {
                    assertionFailure("Can't find downloaded file for url: \(url)")
                    promise(.failure(URLError(.fileDoesNotExist)))
                    return
                }
                
                do {
                    try FileManager.default.moveItemSafe(at: tempLocation, to: targetLocation)
                    promise(.success(targetLocation))
                } catch {
                    assertionFailure("Can't move file to: \(targetLocation), error: \(error)")
                    promise(.failure(URLError(.cannotMoveFile)))
                }
            }
            task.resume()
        }
        
        return downloadPublisher
            .mapToDownloadWebError()
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func downloadToDiskWithProgress(url: URL, to targetLocation: URL)
    -> AnyPublisher<DownloadState, DownloadWebError> {
        session
            .downloadWithProgressPublisher(for: url)
            .tryMapOutputWithFailureAndMoveItem(to: targetLocation)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

fileprivate extension DownloadWithProgressPublisher {
    func tryMapOutputWithFailureAndMoveItem(to targetLocation: URL)
    -> AnyPublisher<DownloadRepository.DownloadState, DownloadWebError> {
        self.mapToDownloadWebError()
            .tryMap {
                switch $0 {
                case .notStarted:
                    return .inProgress(percent: 0)
                case .inProgress(let percent):
                    return .inProgress(percent: percent)
                case .finished(let tempLocation): // TODO: update this
                    do {
                        try FileManager.default.moveItemSafe(at: tempLocation, to: targetLocation)
                        return .finished(targetFileLocation: targetLocation)
                    } catch {
                        assertionFailure("Can't move file to: \(targetLocation), error: \(error)")
                        throw DownloadWebError.storageError(error)
                    }
                }
            }
            .mapError { $0 as! DownloadWebError }
            .eraseToAnyPublisher()
    }
}

fileprivate extension Publisher where Failure == URLError {
    func mapToDownloadWebError() -> Publishers.MapError<Self, DownloadWebError> {
        self.mapError {
            switch $0.code {
            case .timedOut: return .responseTimeOut
            case .badURL: return .incorrectURL
            case .badServerResponse: return .unexpectedResponse
            case .fileDoesNotExist: return .storageError($0)
            case .cannotMoveFile: return .storageError($0)
            default: return .urlError($0)
            }
        }
    }
}
