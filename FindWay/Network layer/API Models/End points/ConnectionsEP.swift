//
//  ConnectionsEndPoint.swift
//  FindWay
//
//  Created by Oleksandr Haidaiev on 26.03.2023.
//

import Foundation

enum ConnectionsEndPoint: Endpoint {
    case getConnections
    
    var path: String {
        switch self {
        case .getConnections: return "TuiMobilityHub/ios-code-challenge/master/connections.json"
        }
    }
    
    var acceptType: MIMEType {
        switch self {
        case .getConnections: return .plain
        }
    }
}
