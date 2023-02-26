//
//  getRouteFromFile.swift
//  hello-world
//
//  Created by Quinn Patwardhan on 2/23/23.
//

import Foundation
import MapKit

func getRouteFromFile(filename fileName: String) -> [CLLocationCoordinate2D]? {
    var ans : [CLLocationCoordinate2D] = [CLLocationCoordinate2D]();
    if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let jsonData = try decoder.decode([route].self, from: data)
            for i in jsonData {
                ans.append(CLLocationCoordinate2D(latitude: i.shape_pt_lat, longitude: i.shape_pt_lon))
            }
            return ans
        } catch {
            print("error:\(error)")
        }
    }
    return nil
}
