//
//  stopTimeUpdate.swift
//  hello-world
//
//  Created by Quinn Patwardhan on 2/23/23.
//

import Foundation

struct stopTimeUpdate: Codable, Identifiable, Hashable {
    let departure: departure?
    let arrival: arrival?
    let stopId: String
    var id: String {
        stopId
    }
}
