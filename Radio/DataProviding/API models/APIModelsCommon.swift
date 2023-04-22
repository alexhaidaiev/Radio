//
//  APIModelsCommon.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 19.04.2023.
//

enum APIModel { }

extension APIModel {
    struct Head: Codable {
        let status: String
        let title: String?
        let fault: String?
        let faultCode: String?
    }
}
