//
//  GetStationFromStopId.swift
//  hello-world
//
//  Created by Quinn Patwardhan on 2/24/23.
//

import Foundation

func GetStationFromStopId(stopID: Int, stations: [station]) -> station {
    let filtered = stations.filter { $0.stop_id[0] == stopID || ($0.stop_id.count == 2 && $0.stop_id[1] == stopID) }

    if filtered.isEmpty {
        return station(stop_id: [0, 0], stop_name: "error", pretty_stop_name: "", stop_lat: 0, stop_lon: 0, static_stops: [], defaultLine: [])
    }
    return filtered[0]
}
