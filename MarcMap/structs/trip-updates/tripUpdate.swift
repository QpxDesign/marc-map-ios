//
//  tripUpdate.swift
//  hello-world
//
//  Created by Quinn Patwardhan on 2/23/23.
//

import Foundation

struct tripUpdate: Codable, Identifiable, Equatable {
    let trip: trip
    var stopTimeUpdate: [stopTimeUpdate]
    let timestamp: String
    var id: String {
        trip.tripId
    }
}
