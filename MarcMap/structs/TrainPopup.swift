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
    let coordinate: CLLocationCoordinate2D
    var show = false
    let tripID: String?
    let line: String?
    let delay: String?
    let nextStop: String?
    let nextStopETA: String?
    let finalStop: String?
    let finalStopETA: String?
}


struct StationPopup: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    var show = false
    let name: String
}
