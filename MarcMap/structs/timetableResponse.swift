//
//  timetableResponse.swift
//  MarcMap
//
//  Created by Quinn Patwardhan on 9/3/23.
//

import Foundation

struct timetableResponse: Codable, Identifiable {
    let id = UUID()
    let trip_id: String
    let arrival_time: String
}
