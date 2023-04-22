//
//  SearchDataProvider.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 19.04.2023.
//

import Foundation
import Combine

enum SearchDPNetworkError: DataProviderError, WebErrorWithGeneralCase {
    case generalNetwork(_ error: RESTWebError)
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
    enum Category: String {
        case local, music, talk, sport, lang, podcast
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
            .executeRequest(endpoint: endpoint)
            .map { Self.mapToSearch(apiModel: $0) }
            .mapError { Self.map(webError: $0) } // TODO: check `body` and `status` in `head`
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Mapping
    
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

// MARK: - Root data provider models

extension Model {
    struct SearchData: Encodable, Equatable {
        struct Section: Identifiable, Equatable {
            static func == (lhs: Model.SearchData.Section, rhs: Model.SearchData.Section) -> Bool {
                false
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
