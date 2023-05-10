//
//  MapView.swift
//  FindWay
//
//  Created by Oleksandr Haidaiev on 27.03.2023.
//

import SwiftUI
import MapKit

struct MapView: View {
    let fromCoordinates: CLLocationCoordinate2D
    let toCoordinates: CLLocationCoordinate2D
    
    var body: some View {
        Map(coordinateRegion: .constant(region),
            annotationItems: [fromCoordinates, toCoordinates]) { coordinate in
            MapMarker(coordinate: coordinate)
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    private var region: MKCoordinateRegion {
        let centerLatitude = (fromCoordinates.latitude + toCoordinates.latitude) / 2.0
        let centerLongitude = (fromCoordinates.longitude + toCoordinates.longitude) / 2.0
        let center = CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude)
        let latDelta = abs(fromCoordinates.latitude - toCoordinates.latitude) * 1.5
        let lonDelta = abs(fromCoordinates.longitude - toCoordinates.longitude) * 1.5
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        return MKCoordinateRegion(center: center, span: span)
    }
}

extension MapView {
    init(trip: Trip) {
        self.init(fromCoordinates: trip.fromCoordinates.mapToCL2D,
                  toCoordinates: trip.toCoordinates.mapToCL2D)
    }
}

extension CLLocationCoordinate2D: Identifiable {
    public var id: String { "\(latitude),\(longitude)" }
}

extension Coordinates {
    var mapToCL2D: CLLocationCoordinate2D { .init(latitude: y, longitude: x) }
}
