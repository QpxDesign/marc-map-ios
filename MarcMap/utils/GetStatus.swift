//
//  GetStatus.swift
//  MarcMap
//
//  Created by Quinn Patwardhan on 11/3/26.
//

import CoreLocation
import Foundation

let orderedStops: [String: [String]] = ["Brunswick_Fredrick": ["Fredrick", "Monocacy", "Dickerson", "Barnesville", "Boyds", "Germantown", "Metropolitan Grove", "Gaithersburg", "Washington Grove", "Rockville", "Garrett Park", "Kensington", "Silver Spring", "Union Station (DC)"], "Brunswick_WV": ["Martinsburg", "Duffields", "Harpers Ferry", "Brunswick", "Point of Rocks", "Dickerson", "Barnesville", "Boyds", "Germantown", "Metropolitan Grove", "Gaithersburg", "Washington Grove", "Rockville", "Garrett Park", "Kensington", "Silver Spring", "Union Station (DC)"], "Brunswick_Camden": ["Fredrick", "Monocacy", "Dickerson", "Barnesville", "Boyds", "Germantown", "Metropolitan Grove", "Gaithersburg", "Washington Grove", "Rockville", "Garrett Park", "Kensington", "Silver Spring", "College Park", "Laurel", "Camden Station"], "Penn": ["Perryville", "Aberdeen", "Edgewood", "Martin Airport", "Penn Station", "West Baltimore", "Halethorpe", "Bwi Rail Station", "Odenton", "Bowie State", "Seabrook", "New Carrollton", "Union Station (DC)"], "Camden": ["Camden Station", "St Denis", "Dorsey", "Jessup", "Savage", "Laurel Racetrack", "Laurel", "Muirkirk", "Greenbelt", "College Park", "Riverdale", "Union Station (DC)"]]

func getStatus(train: Train, updates: tripUpdate) -> String {
    //  let delta = NSDate().timeIntervalSince1970 + 30
    // let dep_time = Double(stop.departure?.time ?? "0") ?? 0
    // let arr_time = Double(stop.arrival?.time ?? "0") ?? 0
    //   if dep_time > delta || arr_time > delta {
    var route_name = RouteIdToName(routeId: train.vehicle.trip.routeId)

    if updates.stopTimeUpdate.isEmpty {
        return "Unknown"
    }

    if route_name == "Brunswick" {
        if !updates.stopTimeUpdate.filter({ ["11972", "11944", "11971", "11945"].contains($0.stopId) }).isEmpty {
            route_name = "Brunswick_Fredrick"
        } else if !updates.stopTimeUpdate.filter({ $0.stopId == "12006" }).isEmpty {
            route_name = "Brunswick_Camden"
        }
    }
    let origin: station = GetStationFromStopId(stopID: Int(updates.stopTimeUpdate.first?.stopId ?? "") ?? 0)
    let des: station = GetStationFromStopId(stopID: Int(updates.stopTimeUpdate.last?.stopId ?? "") ?? 0)

    if origin.stop_id == des.stop_id {
        return "Unknown"
    }

    let origin_index = orderedStops[route_name]?.firstIndex(of: origin.pretty_stop_name)
    let des_index = orderedStops[route_name]?.firstIndex(of: des.pretty_stop_name)

    if des_index == nil || origin_index == nil || des_index == origin_index {
        return "Unknown"
    }

    var stops_splice = orderedStops[route_name]?[min(origin_index ?? 0, des_index ?? 1) ... max(origin_index ?? 0, des_index ?? 1)]
    if origin_index ?? 0 > des_index ?? 1 {
        stops_splice?.reverse()
    }

    // if its closer to des than station is to des, that means it's passed that station
    // if its within x distance of a station, that means it's at a station
    let des_loc = CLLocation(latitude: des.stop_lat, longitude: -des.stop_lon)
    let train_loc = CLLocation(latitude: train.vehicle.position.latitude, longitude: -train.vehicle.position.longitude)

    let train_distance_to_des = des_loc.distance(from: train_loc)
    var filtered: [String] = []
    for item in stops_splice ?? [] {
        let station_obj = GetStationFromPrettyStationName(name: item)
        let station_loc = CLLocation(latitude: station_obj?.stop_lat ?? 0, longitude: -(station_obj?.stop_lon ?? 0))
        let station_dist = station_loc.distance(from: des_loc)
        if station_dist < train_distance_to_des {
            filtered.append(item)
        }
    }
    if filtered.isEmpty {
        return "Unknown"
    }

    let station_obj = GetStationFromPrettyStationName(name: filtered[0])
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
