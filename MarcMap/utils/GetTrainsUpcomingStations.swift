//
//  GetTrainsUpcomingStations.swift
//  MarcMap
//
//  Created by Quinn Patwardhan on 11/4/26.
//

import CoreLocation
import Foundation

let orderedStops: [String: [String]] = ["Brunswick_Frederick": ["Frederick", "Monocacy", "Dickerson", "Barnesville", "Boyds", "Germantown", "Metropolitan Grove", "Gaithersburg", "Washington Grove", "Rockville", "Garrett Park", "Kensington", "Silver Spring", "Union Station (DC)"], "Brunswick_WV": ["Martinsburg", "Duffields", "Harpers Ferry", "Brunswick", "Point of Rocks", "Dickerson", "Barnesville", "Boyds", "Germantown", "Metropolitan Grove", "Gaithersburg", "Washington Grove", "Rockville", "Garrett Park", "Kensington", "Silver Spring", "Union Station (DC)"], "Brunswick_Camden": ["Martinsburg", "Duffields", "Harpers Ferry", "Brunswick", "Frederick", "Monocacy", "Point of Rocks", "Dickerson", "Barnesville", "Boyds", "Germantown", "Metropolitan Grove", "Gaithersburg", "Washington Grove", "Rockville", "Garrett Park", "Kensington", "Silver Spring", "College Park", "Laurel", "Camden Station"], "Penn": ["Perryville", "Aberdeen", "Edgewood", "Martin Airport", "Penn Station", "West Baltimore", "Halethorpe", "BWI Rail Station", "Odenton", "Bowie State", "Seabrook", "New Carrollton", "Union Station (DC)"], "Camden": ["Camden Station", "St Denis", "Dorsey", "Jessup", "Savage", "Laurel Racetrack", "Laurel", "Muirkirk", "Greenbelt", "College Park", "Riverdale", "Union Station (DC)"]]

func GetTrainsUpcomingStations(data: CombinedTrainObject, stations: [station]) -> [String] {
    var route_name = RouteIdToName(routeId: data.route_id)
        
    if data.stopTimeUpdates.isEmpty {
        return []
    }
        
    if route_name == "Brunswick" {
        if !data.stopTimeUpdates.filter({ ["11972", "11944", "11971", "11945"].contains($0.stopId) }).isEmpty {
            route_name = "Brunswick_Frederick"
        } else if !data.stopTimeUpdates.filter({ $0.stopId == "12006" }).isEmpty {
            route_name = "Brunswick_Camden"
        } else {
            route_name = "Brunswick_WV"
        }
    }
    let origin: station = GetStationFromStopId(stopID: Int(data.stopTimeUpdates.first?.stopId ?? "") ?? 0, stations: stations)
    let des: station = GetStationFromStopId(stopID: Int(data.stopTimeUpdates.last?.stopId ?? "") ?? 0, stations: stations)
        
    if origin.stop_id == des.stop_id {
        return []
    }
        
    let origin_index = orderedStops[route_name]?.firstIndex(of: origin.pretty_stop_name)
    let des_index = orderedStops[route_name]?.firstIndex(of: des.pretty_stop_name)
        
    if des_index == nil || origin_index == nil || des_index == origin_index {
        return []
    }
        
    var stops_splice = orderedStops[route_name]?[min(origin_index ?? 0, des_index ?? 1) ... max(origin_index ?? 0, des_index ?? 1)]
    if origin_index ?? 0 > des_index ?? 1 {
        stops_splice?.reverse()
    }
        
    // if its closer to des than station is to des, that means it's passed that station
    // if its within x distance of a station, that means it's at a station
    let des_loc = CLLocation(latitude: des.stop_lat, longitude: -des.stop_lon)
    let train_loc = CLLocation(latitude: data.position.latitude, longitude: -data.position.longitude)
        
    let train_distance_to_des = des_loc.distance(from: train_loc)
    var filtered: [String] = []
    for item in stops_splice ?? [] {
        let station_obj = GetStationFromPrettyStationName(name: item, stations: stations)
        
        // remove stations that a train isn't stopping at
        
        if data.stopTimeUpdates.filter { station_obj?.stop_id.contains(Int($0.stopId) ?? 0) ?? false }.isEmpty {
            continue
        }
            
        // filter out stations it departed more than 30 seconds ago
        if !data.stopTimeUpdates.filter({ station_obj?.stop_id.contains(Int($0.stopId) ?? 0) ?? false && Double($0.departure?.time ?? String(Double.infinity)) ?? Double.infinity < NSDate().timeIntervalSince1970 - 30 }).isEmpty {
            continue
        }
        
        let station_loc = CLLocation(latitude: station_obj?.stop_lat ?? 0, longitude: -(station_obj?.stop_lon ?? 0))
        let station_dist = station_loc.distance(from: des_loc)
        if station_dist < train_distance_to_des {
            filtered.append(item)
        }
    }
    
    return filtered
}
