//
//  GetStatus.swift
//  MarcMap
//
//  Created by Quinn Patwardhan on 11/3/26.
//

import CoreLocation
import Foundation

func getStatus(data: CombinedTrainObject, stations: [station]) -> String {
    let train_loc = CLLocation(latitude: data.position.latitude, longitude: -data.position.longitude)

    let filtered = GetTrainsUpcomingStations(data: data, stations: stations)

    if filtered.isEmpty {
        return "Unknown"
    }

    let station_obj = GetStationFromPrettyStationName(name: filtered[0], stations: stations)
    let station_loc = CLLocation(latitude: station_obj?.stop_lat ?? 0, longitude: -(station_obj?.stop_lon ?? 0))
    let station_train_dist = station_loc.distance(from: train_loc)
    let threshold_1 = 500.0 // "At ..." (meters)
    let threshold_2 = 1609.0 * 2 // "Approaching ..." (two miles in meters)

    if station_train_dist < threshold_1 {
        return "At \(filtered[0])"
    }
    if station_train_dist < threshold_2 {
        let dist_miles = ((station_train_dist / 1609) * 100).rounded() / 100

        return "Approaching \(filtered[0]) (\(dist_miles)mi away)"
    }
    return "Heading towards \(filtered[0])"
}
