//
//  StationTrainDetails.swift
//  MarcMap
//
//  Created by Quinn Patwardhan on 2/26/23.
//

import Foundation

struct StationTrainDetails :  Codable, Identifiable {
    let id = UUID()
    let tripId : String
    let time : String?
    let line : String
    let delay : Int?
}
