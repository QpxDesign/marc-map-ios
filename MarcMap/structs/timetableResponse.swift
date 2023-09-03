//
//  timetableResponse.swift
//  MarcMap
//
//  Created by Quinn Patwardhan on 9/3/23.
//

import Foundation

struct timetableResponse: Codable, Identifiable {
    let id=UUID()
    let stop_name: String?
    let trains: [String]?
    let times: [String]?
    let error: String?
    let msg: String?

}
