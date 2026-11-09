//
//  arrival.swift
//  hello-world
//
//  Created by Quinn Patwardhan on 2/23/23.
//

import Foundation

struct arrival: Codable, Identifiable, Equatable, Hashable {
    let delay: Int?
    let time: String
    var id: String {
        time
    }
}
