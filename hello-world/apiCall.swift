//
//  apiCall.swift
//  hello-world
//
//  Created by Quinn Patwardhan on 2/22/23.
//

import Foundation
import SwiftUI
class apiCall {
    func getTrains(completion:@escaping ([Train]) -> ()) {
        guard let url = URL(string: "https://api.marcmap.app/mtaAPI") else {
            return }
        
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            print(data)
            let tData = try! JSONDecoder().decode(TrainData.self, from: data!)
            var trains : [Train] = []
            for t in tData.entity {
                var tmp = Train(vehicle: t.vehicle)
                trains.append(tmp)
            }
                       
                        
            DispatchQueue.main.async {
                completion(trains)
            }
        }
        .resume()
        print("-----")
    }
}
