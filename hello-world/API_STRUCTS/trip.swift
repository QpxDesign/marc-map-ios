//
//  trip.swift
//  hello-world
//
//  Created by Quinn Patwardhan on 2/22/23.
//

import SwiftUI

struct trip: Codable, Identifiable {
    let id = UUID()
    let tripId: String
    let routeId: String
    let startDate: String
}
