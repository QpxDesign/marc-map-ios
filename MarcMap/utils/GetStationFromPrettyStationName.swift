//
//  GetStationFromPrettyStationName.swift
//  MarcMap
//
//  Created by Quinn Patwardhan on 11/3/26.
//

import Foundation

func GetStationFromPrettyStationName(name: String, stations: [station]) -> station? {
    let filtered = stations.filter {
        $0.pretty_stop_name.trimmingCharacters(in: .whitespaces).lowercased() == name.trimmingCharacters(in: .whitespaces).lowercased()
    }

    if filtered.isEmpty {
        print("ERROR RESOLVING STATION FROM PRETTY_NAME: \(name)")
        return nil
    }
    return filtered[0]
}
