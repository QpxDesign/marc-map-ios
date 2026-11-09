//
//  TrainData.swift
//  hello-world
//
//  Created by Quinn Patwardhan on 2/22/23.
//

import SwiftUI

struct TrainData: Codable, Identifiable, Equatable {
    let header: APIHeader
    let entity: [Train]
    var id: String {
        self.header.timestamp
    }
}
