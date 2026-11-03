//
//  TrainPopup.swift
//  MarcMap
//
//  Created by Quinn Patwardhan on 11/11/23.
//

import Foundation
import MapKit

struct TrainPopup: Identifiable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
    var show: Bool = true
    var expired: Bool = false
    let tripID: String?
}

struct StationPopup: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    var show = false
    let name: String
    let station: station
}
