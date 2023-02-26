//
//  route.swift
//  hello-world
//
//  Created by Quinn Patwardhan on 2/23/23.
//

import Foundation
import SwiftUI

struct route: Codable, Identifiable {
    let id = UUID()
    let shape_pt_lat: Double
    let shape_pt_lon: Double
    
}
