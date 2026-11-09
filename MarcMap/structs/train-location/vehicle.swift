//
//  vehicle.swift
//  hello-world
//
//  Created by Quinn Patwardhan on 2/22/23.
//

import SwiftUI

struct vehicle: Codable, Identifiable, Equatable {
    let trip: trip
    let position: position
    let timestamp: String
    let vehicle: sub_vehicle
    var id: String {
        vehicle.id
    }
}

struct sub_vehicle: Codable, Identifiable, Equatable {
    let id: String
}
