//
//  getStations.swift
//  MarcMap
//
//  Created by Quinn Patwardhan on 2/26/23.
//

import Foundation
func getStations() -> [station] {
    var stations : [station] = [station]()
    if let url = Bundle.main.url(forResource: "StopData", withExtension: "json") {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let jsonData = try decoder.decode([station].self, from: data)
            for i in jsonData {
                stations.append(i)
            }
            return stations
        } catch {
            print("error:\(error)")
        }
    }
    return stations
}
