//
//  arrival.swift
//  hello-world
//
//  Created by Quinn Patwardhan on 2/23/23.
//

import Foundation
struct arrival:Codable, Identifiable {
    let id=UUID()
    let delay: Int?
    let time: String
}
