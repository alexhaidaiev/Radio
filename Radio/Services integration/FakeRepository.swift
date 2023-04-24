//
//  FakeRepository.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 24.04.2023.
//

import Foundation

#if DEBUG
typealias FakeJSONRepository = LocalJSONRepository

protocol FakeRepository { }
protocol FakeRepositoryWithJSONsLoading: FakeRepository { }

extension FakeRepositoryWithJSONsLoading {
    //where Self: StorageDataProvider, SRepository == LocalJSONRepository { // check if we need this
    static func map<T>(jsonLoadingError error: LocalJSONRepository.RepositoryError) -> T
    where T: ErrorWithGeneralRESTWebErrorCase {
        .generalRESTError(.backend(.init(code: 400,
                                         reason: "getDataFromJSONFailed \(error)",
                                         faultCode: error.localizedDescription)))
    }
}

// MARK: Fakes setup

extension LocalJSONRepository {
    static var fake: Self = LocalJSONRepository()
}
extension RESTWebRepository {
    static var fake: Self = .init(session: .shared,
                                  requestBuilderParams: .init(baseURL: "",
                                                              commonQueryParameters: []),
                                  requestBuilderType: URLRequestBuilder.self)
}
#endif
