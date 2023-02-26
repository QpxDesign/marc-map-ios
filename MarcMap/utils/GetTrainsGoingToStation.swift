//
//  GetTrainsGoingToStation.swift
//  MarcMap
//
//  Created by Quinn Patwardhan on 2/26/23.
//

import Foundation

func GetTrainsGoingToStation(stopId: [Int], trains: [Train], details: [tripUpdate]) -> [StationTrainDetails] {
    var results : [StationTrainDetails] = [StationTrainDetails]()
    for si in stopId {

        for d in details {
            for s in d.stopTimeUpdate {
                if (String(s.stopId) == String(si)) {
                    if (s.departure?.time ?? nil != nil) {
                        if (Double(s.departure?.time ?? "0") ?? 0 > NSDate().timeIntervalSince1970) {
                            results.append(StationTrainDetails(tripId: d.trip.tripId, time: s.arrival?.time ?? s.departure?.time, line: d.trip.routeId, delay: s.arrival?.delay ?? s.departure?.delay))
                        }
                    } else if (s.arrival?.time ?? nil != nil) {
                        if (Double(s.arrival?.time ?? "0") ?? 0 > NSDate().timeIntervalSince1970) {
                            results.append(StationTrainDetails(tripId: d.trip.tripId, time: s.arrival?.time ?? s.departure?.time, line: d.trip.routeId, delay: s.arrival?.delay ?? s.departure?.delay))

                        }
                        
                    }
                  
                }
            }
            
        }
    }

    return results
}
