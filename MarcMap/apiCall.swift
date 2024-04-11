//
//  apiCall.swift
//  hello-world
//
//  Created by Quinn Patwardhan on 2/22/23.
//

import Foundation
import SwiftUI
class apiCall {
    func getTrains(completion:@escaping ([Train]?) -> ()) {
        if UserDefaults.standard.string(forKey: "user_id") == nil || UserDefaults.standard.string(forKey: "user_id") == "nil" {
            UserDefaults.standard.set(NSUUID().uuidString, forKey: "user_id")
        }
        guard let url = URL(string: "https://api.marcmap.app/mtaAPI?\(UserDefaults.standard.string(forKey: "user_id") ??  "")") else {
            return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if ((error) != nil) {return}
            guard let tData = try? JSONDecoder().decode(TrainData?.self, from: data ?? Data()) else {return}
            var trains : [Train] = []
            for t in tData.entity  {
                var tmp = Train(vehicle: t.vehicle)
                trains.append(tmp)
            }
            
            
            DispatchQueue.main.async {
                completion(trains)
            }
            
        }
        .resume()
    }
    func getTripUpdates(completion:@escaping ([tripUpdate]?) -> ()) {
        if UserDefaults.standard.string(forKey: "user_id") == nil || UserDefaults.standard.string(forKey: "user_id") == "nil" {
            UserDefaults.standard.set(NSUUID().uuidString, forKey: "user_id")
        }
        guard let url = URL(string: "https://api.marcmap.app/tripUpdatesAPI?\(UserDefaults.standard.string(forKey: "user_id") ??  "")") else {
            return }
        
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            guard let tData = try? JSONDecoder().decode(TripUpdateData.self, from: data ?? Data()) else {return}
            var updates : [tripUpdate] = []
            for t in tData.entity  {
                var tmp = t.tripUpdate
                updates.append(tmp)
            }
            DispatchQueue.main.async {
                completion(updates)
            }
        }
        .resume()
        
    }
    func getTimetable( lineName: String, date: String,  direction :String, completion:@escaping ([timetableResponse]?) -> ()) {
        if UserDefaults.standard.string(forKey: "user_id") == nil || UserDefaults.standard.string(forKey: "user_id") == "nil" {
            UserDefaults.standard.set(NSUUID().uuidString, forKey: "user_id")
        }
        print("https://api.marcmap.app/getTimetable?line=\(lineName)&date=\(date.replacingOccurrences(of: "/", with: "%2F"))&direction=\(direction)&dev_id=\(UserDefaults.standard.string(forKey: "user_id") ??  "")")
        guard let url = URL(string: "https://api.marcmap.app/getTimetable?line=\(lineName)&date=\(date.replacingOccurrences(of: "/", with: "%2F"))&direction=\(direction)&dev_id=\(UserDefaults.standard.string(forKey: "user_id") ??  "")") else {
            return }
        
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            guard let tData = try? JSONDecoder().decode([timetableResponse].self, from: data ?? Data()) else {
                print("failed to fetch timetables")
                return
            }
            DispatchQueue.main.async {
                completion(tData)
            }
        }
        .resume()
        
    }
    
}
