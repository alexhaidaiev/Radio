//
//  DownloadWithProgressPublisher.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 29.04.2023.
//

import Foundation
import Combine

// Source - https://theswiftdev.com/how-to-download-files-with-urlsession-using-combine-publishers-and-subscribers/

struct DownloadWithProgressPublisher: Publisher {
    typealias Output = State
    typealias Failure = URLError

    enum State: Equatable {
        case notStarted
        /// `percent` is a value in the range [0...1]
        case inProgress(percent: Double)
        case finished(tempFileLocation: URL)
    }
    
    let session: URLSession
    let request: URLRequest
    
    func receive<S: Subscriber>(subscriber: S) where Output == S.Input, Failure == S.Failure {
        subscriber.receive(subscription: DownloadTaskWithProgressSubscription(
            session: session,
            request: request,
            subscriber: subscriber)
        )
    }
}

fileprivate class DownloadTaskWithProgressSubscription<SubscriberT: Subscriber>: Subscription
where SubscriberT.Input == DownloadWithProgressPublisher.State,
      SubscriberT.Failure == DownloadWithProgressPublisher.Failure {
    
    private let session: URLSession
    private let request: URLRequest
    private let subscriber: SubscriberT?
    
    private var downloadTask: URLSessionDownloadTask?
    private var cancellable = Set<AnyCancellable>()
    
    init(session: URLSession, request: URLRequest, subscriber: SubscriberT) {
        self.session = session
        self.request = request
        self.subscriber = subscriber
    }
    
    func request(_ demand: Subscribers.Demand) {
        guard demand > 0 else { return }
        
        guard let url = request.url else {
            sendFailure(error: URLError(.badURL))
            return
        }
        
        downloadTask = session.downloadTask(with: request) { [weak self]
            tempLocation, response, error in
            
            guard let self = self else { return }
            
            if let urlError = error as? URLError {
                self.sendFailure(error: urlError)
                return
            }
            guard let response = response as? HTTPURLResponse,
                  (200..<300) ~= response.statusCode else {
                self.sendFailure(error: URLError(.badServerResponse))
                return
            }
            guard let tempLocation else {
                assertionFailure("Can't find downloaded file for url: \(url)")
                self.sendFailure(error: URLError(.fileDoesNotExist))
                return
            }
            self.sendValue(.finished(tempFileLocation: tempLocation))
            self.sendSuccessCompletion()
            
            // TODO: decide if we should move files here or outside
//            do {
//                try FileManager.default.moveItemSafe(at: tempLocation, to: targetLocation)
//                self.sendValue(.finished(tempFileLocation: targetLocation))
//                self.sendSuccessCompletion()
//            } catch {
//                assertionFailure("Can't move file to: \(targetLocation), error: \(error)")
//                self.sendFailure(error: URLError(.cannotMoveFile))
//            }
        }
        
        downloadTask?
            .progress
            .publisher(for: \.fractionCompleted)
            .sink { [weak self] fractionValue in
                self?.sendValue(.inProgress(percent: fractionValue))
            }
            .store(in: &cancellable)
        
        downloadTask?.resume()
    }
    
    func cancel() {
        downloadTask?.cancel()
        cancellable.removeAll()
    }
    
    // MARK: Private
    
    private func sendValue(_ value: SubscriberT.Input) {
        _ = subscriber?.receive(value)
    }
    
    private func sendFailure(error: SubscriberT.Failure) {
        subscriber?.receive(completion: .failure(error))
    }

    private func sendSuccessCompletion() {
        _ = subscriber?.receive(completion: .finished)
    }
}

// MARK: - Helpers

extension URLSession {
    func downloadWithProgressPublisher(for url: URL) -> DownloadWithProgressPublisher {
        downloadWithProgressPublisher(for: .init(url: url))
    }
    
    func downloadWithProgressPublisher(for request: URLRequest) -> DownloadWithProgressPublisher {
        .init(session: self, request: request)
    }
}
