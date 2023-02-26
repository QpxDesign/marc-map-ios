//
//  vehicle.swift
//  hello-world
//
//  Created by Quinn Patwardhan on 2/22/23.
//

import SwiftUI

struct vehicle: Codable, Identifiable {
    let id = UUID()
    let trip: trip
    let position : position
    let timestamp : String
}
