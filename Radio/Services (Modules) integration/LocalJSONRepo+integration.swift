//
//  LocalJSONRepository+integration.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 17.04.2023.
//

#if DEBUG
// TODO: check and move this to `FakeRepositoryWithJSONsLoading` if needed
extension LocalJSONRepository: FakeStorageRepository {
    func getFakeData<T: Decodable>(from: any FakeJSONFile) -> AnyRPublisher<T, RepositoryError> {
        getData(for: RequestParameters(fileName: from.rawValue,
                                       fileSubdirectory: from.subdirectory))
    }
}
#endif
