//
//  UISupportTypes.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 25.04.2023.
//

import Foundation

class ViewUpdater: ObservableObject {
    func notifyViewToRedraw() {
        objectWillChange.send()
    }
}
