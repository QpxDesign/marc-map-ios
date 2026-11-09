//
//  timetableResponse.swift
//  MarcMap
//
//  Created by Quinn Patwardhan on 9/3/23.
//

import Foundation

struct timetableResponse: Codable, Identifiable {
    let trip_id: String
    let arrival_time: String
    let headsign: String
    var id: String {
        trip_id
    }
}
