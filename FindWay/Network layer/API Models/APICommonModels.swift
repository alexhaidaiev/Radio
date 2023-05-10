//
//  APICommonModels.swift
//  FindWay
//
//  Created by Oleksandr Haidaiev on 24.03.2023.
//

import Foundation

enum API { }

extension API {
    struct Coordinates: Decodable {
        let from: Coordinate
        let to: Coordinate
    }

    struct Coordinate: Decodable {
        let lat: Double
        let long: Double
    }
}
