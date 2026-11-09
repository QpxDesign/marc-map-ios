//
//  CombinedTrainObject.swift
//  MarcMap
//
//  Created by Quinn Patwardhan on 11/7/26.
//

import SwiftUI

class CombinedTrainObject: Hashable, Identifiable, ObservableObject {
    static func == (lhs: borrowing CombinedTrainObject, rhs: borrowing CombinedTrainObject) -> Bool {
        lhs.trip_id == rhs.trip_id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(trip_id)
        hasher.combine(route_id)
    }

    @Published var trip_id: String
    @Published var route_id: String
    @Published var position: position
    @Published var position_timestamp: String
    @Published var stopTimeUpdates: [stopTimeUpdate]
    @Published var stopupdate_timestamp: String
    @Published var id: String

    init(trip_id: String, route_id: String, position: position, position_timestamp: String, stopTimeUpdates: [stopTimeUpdate], stopupdate_timestamp: String) {
        self.trip_id = trip_id
        self.route_id = route_id
        self.position = position
        self.position_timestamp = position_timestamp
        self.stopTimeUpdates = stopTimeUpdates
        self.stopupdate_timestamp = stopupdate_timestamp
        self.id = trip_id
    }
}
