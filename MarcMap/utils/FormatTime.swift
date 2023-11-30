//
//  FormatTime.swift
//  hello-world
//
//  Created by Quinn Patwardhan on 2/24/23.
//

import Foundation

func FormatTime(timestamp: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.timeStyle = .short
    dateFormatter.timeZone = TimeZone(identifier: "America/New_York")

    let date = Date(timeIntervalSince1970: Double(timestamp) ?? 0)
    return dateFormatter.string(from: date)
    
}
