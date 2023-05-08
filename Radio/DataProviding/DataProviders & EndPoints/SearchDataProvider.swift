//
//  SearchDataProvider.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 19.04.2023.
//

import Foundation
import Combine

enum SearchDPNetworkError: DataProviderError, ErrorWithGeneralRESTWebErrorCase {
    case generalRESTError(_ error: RESTWebError)
    case invalidCategory, invalidId
}

protocol SearchDataProviding: NetworkDataProvider
where NetworkDataProviderError == SearchDPNetworkError {
    typealias Category = RealSearchDataProvider.Category
    
    func searchBy(category: Category) -> AnyPublisher<Model.SearchData, SearchDPNetworkError>
    func searchBy(id: String) -> AnyPublisher<Model.SearchData, SearchDPNetworkError>
    func searchUsing(url: URL) -> AnyPublisher<Model.SearchData, SearchDPNetworkError>
}

struct RealSearchDataProvider: SearchDataProviding {
    enum Category: String { // TODO: move to another place
        case local, music, talk, sports, lang, podcast
    }
    
    let networkRepository: RESTWebRepository
    
    func searchBy(category: Category) -> AnyPublisher<Model.SearchData, SearchDPNetworkError> {
        performSearch(endpoint: .byCategory(category.rawValue))
    }
    
    func searchBy(id: String) -> AnyPublisher<Model.SearchData, SearchDPNetworkError> {
        performSearch(endpoint: .byId(id))
    }
    
    func searchUsing(url: URL) -> AnyPublisher<Model.SearchData, SearchDPNetworkError> {
        networkRepository
            .executeRequest(url: url)
            .map { Self.mapToSearch(apiModel: $0) }
            .mapError { Self.map(webError: $0) }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    private func performSearch(endpoint: SearchEndPoint)
    -> AnyPublisher<Model.SearchData, SearchDPNetworkError> {
        networkRepository
            .executeRequest(for: endpoint)
            .map { Self.mapToSearch(apiModel: $0) }
            .mapError { Self.map(webError: $0) } // TODO: check `body` and `status` in `head`
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}

// MARK: - Mapping
 
extension SearchDataProviding
where NRepository == RESTWebRepository, NRepository.RepositoryError == RESTWebError {
    static func map(webError: RESTWebRepository.RepositoryError) -> SearchDPNetworkError {
        return mapBackend(from: webError) { backend in
            switch backend.code {
            case 400 where backend.reason == "Invalid root category": return .invalidCategory
            case 400 where backend.reason == "Invalid ID for browse": return .invalidId
            default: return nil
            }
        }
    }
    
    static func mapToSearch(apiModel: APIModel.SearchRoot) -> Model.SearchData {
        var listOfAudioItems: [Model.SearchDataAudioItem] = []
        var listOfLinkItems: [Model.SearchDataLinkItem] = []
        var sectionsWithLists: [Model.SearchData.Section] = []
        
        apiModel.body.forEach { content in
            if content.children != nil {
                let items = mapToSearchItems(content)
                sectionsWithLists.append(.init(text: content.text,
                                               key: content.key,
                                               items: items))
            } else {
                if content.type == Model.SearchDataItemType.audio.rawValue {
                    listOfAudioItems.append(mapToAudioItem(content))
                } else if content.type == Model.SearchDataItemType.link.rawValue {
                    listOfLinkItems.append(mapToLinkItem(content, key: content.key))
                }
            }
        }
        
        return .init(title: apiModel.head.title ?? "",
                     listOfAudioItems: listOfAudioItems,
                     listOfLinkItems: listOfLinkItems,
                     sectionsWithLists: sectionsWithLists)
    }
}

#if DEBUG
struct FakeSearchDataProvider: SearchDataProviding, FakeRepositoryWithJSONsLoading {
    typealias Category = RealSearchDataProvider.Category
    
    let networkRepository: RESTWebRepository = .fake // TODO: replace to FakeRESTWebRepository()
    // TODO: update FakeRepositoryWithJSONsLoading to remove this property
    private let storageRepository: LocalJSONRepository = .fake
    
    func searchBy(category: Category) -> AnyPublisher<Model.SearchData, SearchDPNetworkError> {
        fakeSearch(jsonFile: category.fakeJSONFile)
    }
    
    func searchBy(id: String) -> AnyPublisher<Model.SearchData, SearchDPNetworkError> {
        fakeSearch(jsonFile: JSONFiles.Fake.Search.Various.mix)
    }
    
    func searchUsing(url: URL) -> AnyPublisher<Model.SearchData, SearchDPNetworkError> {
        var jsonFile: (any FakeJSONFile)? = nil
        let queryParameters = url.queryParameters
        
        if let categoryValue = queryParameters?["c"] {
            let category = Category.init(rawValue: categoryValue)
            jsonFile = category?.fakeJSONFile ?? JSONFiles.Fake.Errors.InvalidRootCategory
            
        } else if let id = queryParameters?["id"] {
            if id == "r0" {
                jsonFile = JSONFiles.Fake.Search.RootCategories.ByLocation // an exception
            } else {
                jsonFile = JSONFiles.Fake.Search.Various.mix // we use a general data in this case
            }
        }
        return fakeSearch(jsonFile: jsonFile ?? JSONFiles.Fake.Errors.invalidID)
    }
    
    private func fakeSearch(jsonFile: any FakeJSONFile)
    -> AnyPublisher<Model.SearchData, SearchDPNetworkError> {
        storageRepository
            .getFakeData(from: jsonFile)
            .fakeAPIDelay
            .map { Self.mapToSearch(apiModel: $0) }
            .mapError {  $0 as LocalJSONDPError }
            .mapError { Self.map(jsonLoadingError: $0) }
            .eraseToAnyPublisher()
    }
    
}

fileprivate extension RealSearchDataProvider.Category {
    var fakeJSONFile: JSONFiles.Fake.Search.RootCategories {
        switch self {
        case .local: return .LocalRadio
        case .music: return .Music
        case .talk: return .Talk
        case .sports: return .Sports
        case .lang: return .ByLanguage
        case .podcast: return .Podcasts
        }
    }
}
#endif

// MARK: - Root data provider models

extension Model {
    struct SearchData: Encodable, Equatable {
        struct Section: Identifiable, Equatable {
            static func == (lhs: Model.SearchData.Section, rhs: Model.SearchData.Section) -> Bool {
                lhs.id == rhs.id
            }
            
            private(set) var id = ModelID()
            
            let text: String
            let key: String?
            let items: [any ModelSearchDataItem]
        }
        
        let title: String
        
        // Only one of these fields should be at the same time
        let listOfAudioItems: [SearchDataAudioItem]
        let listOfLinkItems: [SearchDataLinkItem]
        let sectionsWithLists: [Section]
    }
}

// MARK: Support

extension Model.SearchData.Section: Encodable {
    enum CodingKeys: CodingKey {
        case text, key, items
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(text, forKey: .text)
        try container.encode(key, forKey: .key)
        
        var itemsContainer = container.nestedUnkeyedContainer(forKey: .items)
        for item in items {
            try itemsContainer.encode(item)
        }
    }
}
