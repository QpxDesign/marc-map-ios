//
//  trip.swift
//  hello-world
//
//  Created by Quinn Patwardhan on 2/22/23.
//

import SwiftUI

struct trip: Codable, Identifiable, Equatable {
    let tripId: String
    let routeId: String
    let startDate: String
    var id: String {
        tripId
    }
}
