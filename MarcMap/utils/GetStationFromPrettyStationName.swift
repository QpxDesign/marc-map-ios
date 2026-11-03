//
//  GetStationFromPrettyStationName.swift
//  MarcMap
//
//  Created by Quinn Patwardhan on 11/3/26.
//

import Foundation

func GetStationFromPrettyStationName(name: String) -> station? {
    var ans = [station]()
    if let url = Bundle.main.url(forResource: "StopDataPretty", withExtension: "json") {
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
    let filtered = ans.filter { $0.pretty_stop_name == name }
    return filtered[0]
}
