//
//  GetTrainsGoingToStation.swift
//  MarcMap
//
//  Created by Quinn Patwardhan on 2/26/23.
//

import CoreLocation
import Foundation

func GetTrainsGoingToStation(pretty_stop_name: String, trains: [Train], details: [tripUpdate], stations: [station]) -> [Train] {
    var results: [Train] = []
    for train in trains {
        let updates_matches = details.filter { $0.trip.tripId == train.vehicle.trip.tripId }

        if updates_matches.isEmpty || updates_matches[0].stopTimeUpdate.isEmpty {
            continue
        }

        let filtered = GetTrainsUpcomingStations(train: train, details: updates_matches[0], stations: stations)

        if filtered.contains(pretty_stop_name) {
            results.append(train)
        }
    }

    return results
}
