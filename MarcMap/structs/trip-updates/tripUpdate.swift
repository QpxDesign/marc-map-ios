//
//  tripUpdate.swift
//  hello-world
//
//  Created by Quinn Patwardhan on 2/23/23.
//

import Foundation
struct tripUpdate: Codable, Identifiable {
    let id = UUID()
    let trip: trip
    var stopTimeUpdate: [stopTimeUpdate]
    let timestamp : String
}
