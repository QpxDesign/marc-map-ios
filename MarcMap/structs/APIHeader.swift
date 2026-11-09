//
//  APIHeader.swift
//  hello-world
//
//  Created by Quinn Patwardhan on 2/22/23.
//

import SwiftUI

struct APIHeader: Codable, Identifiable, Equatable {
    let gtfsRealtimeVersion: String
    let incrementality: String
    let timestamp: String
    var id: String {
        timestamp
    }
}
