//
//  GetDelay.swift
//  MarcMap
//
//  Created by Quinn Patwardhan on 11/3/26.
//
// gets instantaneous delay (i.e. delay heading to next stop) in seconds

import Foundation

func GetDelay(updates: tripUpdate) -> Int {
    if updates.stopTimeUpdate.isEmpty {
        return 0
    }
    let threshold = 0.0
    let curr_time = NSDate().timeIntervalSince1970
    for i in updates.stopTimeUpdate.indices {
        let dep = Double(updates.stopTimeUpdate[i].departure?.time ?? String(Double.infinity)) ?? Double.infinity

        if dep < curr_time - threshold && i+1 < updates.stopTimeUpdate.count {
            let next_arr = Double(updates.stopTimeUpdate[i+1].arrival?.time ?? "0.0") ?? 0.0
            if next_arr > curr_time {
                return updates.stopTimeUpdate[i+1].arrival?.delay ?? 0
            }
        }
    }
    return 0
}

// if !updates.stopTimeUpdate.filter { station_obj?.stop_id.contains(Int($0.stopId) ?? 0) ?? false && Double($0.departure?.time ?? String(Double.infinity)) ?? Double.infinity < NSDate().timeIntervalSince1970 - 30 }.isEmpty {
