//
//  GetStationFromStopId.swift
//  hello-world
//
//  Created by Quinn Patwardhan on 2/24/23.
//

import Foundation

func GetStationFromStopId(stopID: Int) -> station {
    var ans : [station] = [station]();
    if let url = Bundle.main.url(forResource: "StopData", withExtension: "json") {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let jsonData = try decoder.decode([station].self, from: data)
            for i in jsonData {
                ans.append(i)
            }
         
        } catch {
            print("error:\(error)")
        }
    }
    if (ans.filter{$0.stop_id==stopID}.isEmpty) {
        return station(stop_id: 0, stop_name: "error", stop_lat: 0, stop_lon: 0);
        
    }
    return ans.filter{$0.stop_id==stopID}[0]
}
