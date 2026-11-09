//
//  DataHolder.swift
//  MarcMap
//
//  Created by Quinn Patwardhan on 10/29/26.
//
import SwiftUI

func loadStations() -> [station] {
    var stations: [station] = []
    if let url = Bundle.main.url(forResource: "StopDataPretty", withExtension: "json") {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let jsonData = try decoder.decode([station].self, from: data)

            for i in jsonData {
                stations.append(i)
            }

        } catch {
            print("error:\(error)")
        }
    }
    return stations
}

class ActiveViewData: ObservableObject {
    @Published var activeTrainID: String = ""
    @Published var activeStationID: String = ""

    init(active_train: String, active_station: String) {
        activeTrainID = active_train
        activeStationID = active_station
    }
}

class MasterViewModel: ObservableObject {
    @Published var headerViewModel: HeaderViewModel = .init()
    @Published var stations: [station] = loadStations()

    @Published var trains: [Train] = []

    @Published var tripUpdates: [tripUpdate] = []

    @Published var data: [CombinedTrainObject] = []

    @Published var isLoading: Bool = true

    func update() {
        apiCall().getTrains { trains in
            apiCall().getTripUpdates { trip_updates in
                DispatchQueue.main.async {
                    let tu: [tripUpdate] = trip_updates ?? []
                    var new: [CombinedTrainObject] = []
                    for train in trains ?? [] {
                        let matching_trip_update = tu.filter { $0.trip.tripId == train.vehicle.trip.tripId }
                        if matching_trip_update.isEmpty {
                            continue
                        }

                        let combined = CombinedTrainObject(trip_id: train.vehicle.trip.tripId, route_id: train.vehicle.trip.routeId, position: train.vehicle.position, position_timestamp: train.vehicle.timestamp, stopTimeUpdates: matching_trip_update[0].stopTimeUpdate, stopupdate_timestamp: matching_trip_update[0].timestamp)
                        new.append(combined)
                    }

                    self.data = new
                    self.isLoading = false
                }
            }
        }
    }

    init() {
        update()
        _ = Timer.scheduledTimer(withTimeInterval: 6, repeats: true) { _ in
            print("updating data")

            self.update()
        }
    }
}

class HeaderViewModel: ObservableObject {
    @Published var top_adjustment: Double
    @Published var initial_top: Double
    @Published var prev: [Double]

    init() {
        top_adjustment = 0.0
        initial_top = 0.0
        prev = []
    }

    func update(newTa: Double, new_initial_top: Double, newPrevItem: Double) {
        top_adjustment = newTa
        initial_top = new_initial_top
        prev.append(newPrevItem)
    }
}

class LocationViewModel: ObservableObject {
    @Published var loc: CLLocationCoordinate2D

    init(supplied_loc: CLLocationCoordinate2D) {
        loc = supplied_loc
    }

    init() {
        loc = .init(latitude: 38.9072, longitude: -77.0369)
    }

    func update(newLoc: CLLocationCoordinate2D) {
        loc = newLoc
    }
}

/*
 class TrainsViewModel: ObservableObject {
     @Published var trains: [Train] = [] {
         willSet {
             objectWillChange.send()
         }
     }

     func updateData() async {
         apiCall().getTrains { t in
             self.trains = t ?? []
         }
     }

     init() async {
         if trains.isEmpty {
             await updateData()
         }
         _ = Timer.scheduledTimer(withTimeInterval: 6, repeats: true) { _ in
             apiCall().getTrains { t in
                 self.trains = t ?? []
             }
         }
     }
 }

 class TripUpdatesViewModel: ObservableObject {
     @Published var tripUpdates: [tripUpdate] = [] {
         willSet {
             objectWillChange.send()
         }
     }

     func updateData() {
         apiCall().getTripUpdates { t in
             self.tripUpdates = t ?? []
         }
     }

     init() {
         if tripUpdates.isEmpty {
             updateData()
         }
         _ = Timer.scheduledTimer(withTimeInterval: 6, repeats: true) { _ in
             self.updateData()
         }
     }
 }

  struct DataHolder {
      @Binding var trainData = [Train]()
      @Binding var isLoadingTrains: Bool
      @Binding var tripUpdateData: [tripUpdate]
      @Binding var isLoadingTripUdates: Bool

      /// initial hydrate and timer
      init() {
          isLoadingTrains = true
          isLoadingTripUdates = true
          apiCall().getTrains { trains in
              isLoadingTrains = false
              trainData = trains ?? []
          }
          apiCall().getTripUpdates { updates in
              tripUpdateData = updates ?? []
          }
          Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
              apiCall().getTrains { trains in
                  trainData = trains ?? []
                  isLoadingTrains = false
              }
              apiCall().getTripUpdates { updates in
                  tripUpdateData = updates ?? []
                  isLoadingTripUdates = false
              }
          }
      }
  }
  */
