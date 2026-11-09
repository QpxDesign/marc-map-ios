//
//  GetDelay.swift
//  MarcMap
//
//  Created by Quinn Patwardhan on 11/3/26.
//
// gets instantaneous delay (i.e. delay heading to next stop) in seconds

import Foundation

func GetDelay(data: CombinedTrainObject) -> Int {
    if data.stopTimeUpdates.isEmpty {
        return 0
    }
    let threshold = 0.0
    let curr_time = NSDate().timeIntervalSince1970
    for i in data.stopTimeUpdates.indices {
        let dep = Double(data.stopTimeUpdates[i].departure?.time ?? String(Double.infinity)) ?? Double.infinity

        if dep < curr_time - threshold && i+1 < data.stopTimeUpdates.count {
            let next_arr = Double(data.stopTimeUpdates[i+1].arrival?.time ?? "0.0") ?? 0.0
            if next_arr > curr_time {
                return data.stopTimeUpdates[i+1].arrival?.delay ?? 0
            }
        }
    }
    return 0
}

// if !updates.stopTimeUpdate.filter { station_obj?.stop_id.contains(Int($0.stopId) ?? 0) ?? false && Double($0.departure?.time ?? String(Double.infinity)) ?? Double.infinity < NSDate().timeIntervalSince1970 - 30 }.isEmpty {
