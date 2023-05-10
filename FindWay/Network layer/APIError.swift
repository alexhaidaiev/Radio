//
//  APIError.swift
//  FindWay
//
//  Created by Oleksandr Haidaiev on 24.03.2023.
//

import Foundation

// TODO: split to NetworkError and APIError
enum APIError: Error, Equatable {
    enum BackEnd: Error, Equatable {
        case serverUnavailable
        case badRequest
        case noAccess
        case unauthorised
        case concrete(code: Int, reason: String)
        // ... etc
    }
    case unknown
    case cantCreateRequest
    case unexpectedResponse
    case decoding
    case network
    case backend(_ type: BackEnd)
    // ... etc
    
    var asConcreteBackend: (code: Int, reason: String)? {
        if case .backend(let type) = self,
           case .concrete(let code, let reason) = type {
            return (code, reason)
        }
        return nil
    }
    
    var isGlobal: Bool {
        // list all errors that should be handled in the same way no matter were they happen
        return false
    }
}

extension APIError: CustomStringConvertible {
    var description: String {
        switch self {
        case .unknown: return "Unknown error"
        case .cantCreateRequest: return "Incorrect request"
        case .unexpectedResponse: return "Incorrect response"
        case .decoding: return "Incorrect response content"
        case .network: return "Network issue"
        case .backend(let type):
            switch type {
            case .serverUnavailable: return "Server doesn't respond"
            case .badRequest: return "Incorrect request parameters"
            case .noAccess: return "Access denied"
            case .unauthorised: return "Authorisation issue"
            case .concrete(let code, let reason): return "Code: \(code), reason: \(reason)"
            }
        }
    }
}
