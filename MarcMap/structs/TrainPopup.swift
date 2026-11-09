//
//  TrainPopup.swift
//  MarcMap
//
//  Created by Quinn Patwardhan on 11/11/23.
//

import Foundation
import MapKit

struct TrainPopup {
    var trainData: CombinedTrainObject
    var show: Bool = true
    var expired: Bool = false
}

extension TrainPopup: Identifiable {
    var id: String {
        trainData.trip_id ?? UUID().uuidString
    }
}

struct StationPopup: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    var show = false
    let name: String
    let station: station
}
