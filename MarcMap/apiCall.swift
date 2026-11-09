//
//  apiCall.swift
//  hello-world
//
//  Created by Quinn Patwardhan on 2/22/23.
//

import Foundation
import SwiftUI

class apiCall { nonisolated func getTrains(completion: @escaping ([Train]?) -> ()) {
    if UserDefaults.standard.string(forKey: "user_id") == nil || UserDefaults.standard.string(forKey: "user_id") == "nil" {
        UserDefaults.standard.set(NSUUID().uuidString, forKey: "user_id")
    }
    guard let url = URL(string: "https://api.marcmap.app/mtaAPI?\(UserDefaults.standard.string(forKey: "user_id") ?? "")") else {
        print("WOOPS! 1")
        DispatchQueue.main.async {
            completion([])
        }
        return
    }

    URLSession.shared.dataTask(with: url) { data, _, error in
        if error != nil {
            print("Error Decoding Data (1) \(error)")
            return
        }
        let tData: TrainData?
        do {
            tData = try JSONDecoder().decode(TrainData?.self, from: data ?? Data())
        }
        catch {
            print("Error Decoding Data (2) \(error)")
            DispatchQueue.main.async {
                completion([])
            }
            return
        }
        if tData == nil {
            DispatchQueue.main.async {
                completion([])
            }
            return
        }

        var trains: [Train] = []

        for t in tData?.entity ?? [] {
            let tmp = Train(id: t.id, vehicle: t.vehicle)
            trains.append(tmp)
        }

        DispatchQueue.main.async {
            completion(trains)
        }
    }
    .resume()
}

nonisolated func getTripUpdates(completion: @escaping ([tripUpdate]?) -> ()) {
    if UserDefaults.standard.string(forKey: "user_id") == nil || UserDefaults.standard.string(forKey: "user_id") == "nil" {
        UserDefaults.standard.set(NSUUID().uuidString, forKey: "user_id")
    }
    guard let url = URL(string: "https://api.marcmap.app/tripUpdatesAPI?\(UserDefaults.standard.string(forKey: "user_id") ?? "")") else {
        DispatchQueue.main.async {
            completion([])
        }
        return
    }

    URLSession.shared.dataTask(with: url) { data, _, _ in
        guard let tData = try? JSONDecoder().decode(TripUpdateData.self, from: data ?? Data()) else { return }
        var updates: [tripUpdate] = []
        for t in tData.entity ?? [] {
            let tmp = t.tripUpdate
            updates.append(tmp)
        }
        DispatchQueue.main.async {
            completion(updates)
        }
    }
    .resume()
}

func getTimetable(lineName: String, day_of_week: Int, direction: String, stop_id: String, completion: @escaping ([timetableResponse]?) -> ()) {
    if UserDefaults.standard.string(forKey: "user_id") == nil || UserDefaults.standard.string(forKey: "user_id") == "nil" {
        UserDefaults.standard.set(NSUUID().uuidString, forKey: "user_id")
    }
    // https://api.marcmap.app/getTimetableNew
    guard let url = URL(string: "https://api.marcmap.app/getTimetableNew?line=\(lineName)&day_of_week=\(day_of_week)&direction=\(direction)&stop_id=\(stop_id)&dev_id=\(UserDefaults.standard.string(forKey: "user_id") ?? "")") else {
        return
    }

    URLSession.shared.dataTask(with: url) { data, _, _ in
        guard let tData = try? JSONDecoder().decode([timetableResponse].self, from: data ?? Data()) else {
            return
        }
        DispatchQueue.main.async {
            completion(tData)
        }
    }
    .resume()
}

func getSchedule(trip_id: String, completion: @escaping ([stopTimeUpdate]?) -> ()) {
    if UserDefaults.standard.string(forKey: "user_id") == nil || UserDefaults.standard.string(forKey: "user_id") == "nil" {
        UserDefaults.standard.set(NSUUID().uuidString, forKey: "user_id")
    }
    // https://api.marcmap.app/getTimetableNew
    guard let url = URL(string: "https://api.marcmap.app/getTrainSchedule?trip_id=\(trip_id)&dev_id=\(UserDefaults.standard.string(forKey: "user_id") ?? "")") else {
        return
    }

    URLSession.shared.dataTask(with: url) { data, _, _ in
        guard let tData = try? JSONDecoder().decode([stopTimeUpdate].self, from: data ?? Data()) else {
            return
        }
        DispatchQueue.main.async {
            completion(tData)
        }
    }
    .resume()
}
}
