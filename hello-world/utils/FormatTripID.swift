//
//  FormatTripID.swift
//  hello-world
//
//  Created by Quinn Patwardhan on 2/22/23.
//

import Foundation

func FormatTripId(tripId : String) -> String {
    return tripId.replacingOccurrences(of: "Train", with: "Train ")
}
