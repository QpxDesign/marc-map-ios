//
//  GetTrainsGoingToStation.swift
//  MarcMap
//
//  Created by Quinn Patwardhan on 2/26/23.
//

import CoreLocation
import Foundation

func GetTrainsGoingToStation(pretty_stop_name: String, data: [CombinedTrainObject], stations: [station]) -> [CombinedTrainObject] {
    var results: [CombinedTrainObject] = []
    for train in data {
        let filtered = GetTrainsUpcomingStations(data: train, stations: stations)

        if filtered.contains(pretty_stop_name) {
            results.append(train)
        }
    }

    return results
}
