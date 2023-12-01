//
//  GetTrainsGoingToStation.swift
//  MarcMap
//
//  Created by Quinn Patwardhan on 2/26/23.
//

import Foundation

func GetTrainsGoingToStation(stopId: [Int], trains: [Train], details: [tripUpdate]) -> [StationTrainDetails] {
    print("GetTrainsGoingToStation fired")
    var results : [StationTrainDetails] = [StationTrainDetails]()
    for si in stopId {
        print("GTGTS - 1")
        for d in details {
            print("GTGTS - 2")
            for s in d.stopTimeUpdate {
                print("GTGTS - 3")
                if (String(s.stopId) == String(si)) {
                    print("GTGTS - 4")
                    if (s.departure?.time ?? nil != nil) {
                        print("GTGTS - 5")
                        print((Int(s.departure?.time ?? "0")!) - Int(NSDate().timeIntervalSince1970))
                        if (Double(s.departure?.time ?? "0")! > NSDate().timeIntervalSince1970) {
                            results.append(StationTrainDetails(tripId: d.trip.tripId, time: s.arrival?.time ?? s.departure?.time, line: d.trip.routeId, delay: s.arrival?.delay ?? s.departure?.delay))
                        }
                    } else if (s.arrival?.time ?? nil != nil) {
                        print("GTGTS - 6")
                        if (Double(s.arrival?.time ?? "0")! > NSDate().timeIntervalSince1970) {
                            results.append(StationTrainDetails(tripId: d.trip.tripId, time: s.arrival?.time ?? s.departure?.time, line: d.trip.routeId, delay: s.arrival?.delay ?? s.departure?.delay))

                        }
                        
                    }
                  
                }
            }
            
        }
    }
    print("BEEPBOOP: " + String(results.count))
    return results
}
