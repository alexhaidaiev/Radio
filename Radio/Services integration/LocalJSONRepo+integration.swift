//
//  LocalJSONRepository+integration.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 17.04.2023.
//

#if DEBUG
protocol FakeJSONFile: RawRepresentable where Self.RawValue == String  {
    var subdirectory: String? { get }
}

enum JSONFiles {
    enum FakeMainCategories: String, FakeJSONFile {
        case `default`
        
        var subdirectory: String? { "Fakes/MainCategories" }
    }
    enum FakeLocalRadio: String, FakeJSONFile {
        case `default`
        case onlyKissFM = "OnlyKissFM"
        
        var subdirectory: String? { "Fakes/LocalRadio" }
    }
    // TODO: add all types and fake JSONs
}

extension LocalJSONRepository: FakeStorageRepository {
    func getFakeData<T: Decodable>(from: any FakeJSONFile) -> AnyRPublisher<T, RepositoryError> {
        getData(for: RequestParameters(fileName: from.rawValue,
                                       fileSubdirectory: from.subdirectory))
    }
}
#endif
