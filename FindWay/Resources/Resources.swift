//
//  Resources.swift
//  FindWay
//
//  Created by Oleksandr Haidaiev on 29.03.2023.
//

import Foundation

protocol TextResources {
    associatedtype Text: RawRepresentable where Text.RawValue == String
    static func text(_ textType: Text) -> String
}
extension TextResources {
    static func text(_ textType: Text) -> String {
        NSLocalizedString(textType.rawValue, comment: "") 
    }
    
    /* To add any String enum, not only from `TextResources`. Not sure if it should be available
    static func text<T>(_ textType: T) -> String where T: RawRepresentable, T.RawValue == String {
        textType.rawValue
    }
    */
}

// TODO: move all values to localizable.strings and introduce keys in format `global_keyDescription`
// do the same for screen specific keys, using format - `screen/uniqueView_component_element_state`
enum GlobalR: TextResources {
    enum Text: String {
        case loading = "Loading ..."
        case unknownError = "Unknown error, please try later"
        case alertConfirm = "Ok"
        case alertCancel = "Cancel"
        // ... etc.
    }
    // TODO: add color pallet, fonts, icons, etc
}

