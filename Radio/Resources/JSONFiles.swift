//
//  JSONFiles.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 24.04.2023.
//

enum JSONFiles { }
    
#if DEBUG
protocol FakeJSONFile: RawRepresentable where Self.RawValue == String  {
    var subdirectory: String? { get }
}

extension JSONFiles {
    enum Fake {
        enum Errors: String, FakeJSONFile {
            case invalidID, InvalidRootCategory
            
            var subdirectory: String? { "FakeJSONs/Errors" }
        }
        
        enum Root: String, FakeJSONFile {
            case MainCategories
            
            var subdirectory: String? { "FakeJSONs/Root" }
        }
        
        enum Search {
            enum RootCategories: String, FakeJSONFile {
                case LocalRadio, Music, Talk, Sports, ByLanguage, Podcasts
                case ByLocation // WARNING: it uses `id` query item instead of a category
                
                var subdirectory: String? { "FakeJSONs/Search/RootCategories" }
            }
            
            enum Various: String, FakeJSONFile {
                case mix = "Music-mix"
                case topic = "Music-topic"
                case show = "Podcasts-show"
                case station = "Talks-station"
                
                var subdirectory: String? { "FakeJSONs/Search/Various" }
            }
        }
    }
}
#endif
