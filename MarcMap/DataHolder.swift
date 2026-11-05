//
//  DataHolder.swift
//  MarcMap
//
//  Created by Quinn Patwardhan on 10/29/26.
//
import SwiftUI

class TrainsViewModel: ObservableObject {
    @Published var trains: [Train] = []
    @Published var isLoading = true

    func updateData() {
        apiCall().getTrains { t in
            self.isLoading = false
            self.trains = t ?? []
        }
    }

    init() {
        if trains.isEmpty {
            updateData()
        }
        _ = Timer.scheduledTimer(withTimeInterval: 6, repeats: true) { _ in
            self.updateData()
        }
    }
}

class TripUpdatesViewModel: ObservableObject {
    @Published var tripUpdates: [tripUpdate] = []
    @Published var isLoading = false

    func updateData() {
        apiCall().getTripUpdates { t in
            self.isLoading = false
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

/*
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
