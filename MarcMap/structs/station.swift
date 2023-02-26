//
//  station.swift
//  hello-world
//
//  Created by Quinn Patwardhan on 2/24/23.
//

import Foundation
struct station: Codable, Identifiable {
    let id=UUID()
    let stop_id: [Int]
    let stop_name: String
    let stop_lat: Double
    let stop_lon: Double
}
