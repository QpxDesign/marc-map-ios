//
//  position.swift
//  hello-world
//
//  Created by Quinn Patwardhan on 2/22/23.
//

import SwiftUI

struct position: Codable, Identifiable {
    let id = UUID()
    let latitude: Float
    let longitude: Float

}
