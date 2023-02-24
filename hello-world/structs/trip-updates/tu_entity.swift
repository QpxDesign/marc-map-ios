//
//  tu_entity.swift
//  hello-world
//
//  Created by Quinn Patwardhan on 2/23/23.
//

import Foundation
struct tu_entity: Codable, Identifiable {
    let id = UUID()
    let tripUpdate: tripUpdate
   
}
