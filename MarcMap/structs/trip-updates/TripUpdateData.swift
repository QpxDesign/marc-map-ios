//
//  TripUpdateData.swift
//  hello-world
//
//  Created by Quinn Patwardhan on 2/23/23.
//

import Foundation

struct TripUpdateData: Codable, Identifiable {
    let id = UUID()
    let header: APIHeader
    let entity: [tu_entity]
}
