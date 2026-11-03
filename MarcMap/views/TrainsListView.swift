//
//  TrainsListView.swift
//  hello-world
//
//  Created by Quinn Patwardhan on 2/22/23.
//

import CoreLocation
import Foundation
import StoreKit
import SwiftUI

@available(iOS 16.0, *)
struct TrainsListView: View {
    // 1.
    @State var userLocation: CLLocation?
    @ObservedObject var trainsViewModel: TrainsViewModel
    @ObservedObject var tripUpdatesViewModel: TripUpdatesViewModel
    @State var showDonateAlert: Bool = false
    @Environment(\.requestReview) private var requestReview

    let manager = LocationManager()

    var body: some View {
        VStack {
            HeaderView(title: "Trains").onAppear {
                manager.requestLocation()
                userLocation = manager.location

                trainsViewModel.trains.sort {
                    let a1 = CLLocation(latitude: $0.vehicle.position.latitude, longitude: $0.vehicle.position.longitude)
                    let d1 = a1.distance(from: userLocation ?? CLLocation(latitude: 38.9072, longitude: -77.0369))
                    let a2 = CLLocation(latitude: $1.vehicle.position.latitude, longitude: $1.vehicle.position.longitude)
                    let d2 = a2.distance(from: userLocation ?? CLLocation(latitude: 38.9072, longitude: -77.0369))
                    print(d1)
                    return d1 < d2
                }
            }
            if trainsViewModel.isLoading || tripUpdatesViewModel.isLoading {
                Text("Loading...")
                Spacer()
            } else if !trainsViewModel.trains.isEmpty && !tripUpdatesViewModel.tripUpdates.isEmpty {
                List(trainsViewModel.trains, id: \.id) { train in
                    VStack(alignment: .leading) {
                        NavigationLink(destination: TrainDetailedView(tripId: train.vehicle.trip.tripId, trainsViewModel: trainsViewModel, tripUpdatesViewModel: tripUpdatesViewModel)) {
                            let matching_trip_update = tripUpdatesViewModel.tripUpdates.filter { $0.trip.tripId == train.vehicle.trip.tripId }
                            HStack {
                                if matching_trip_update.isEmpty {
                                    Text(FormatTripId(tripId: train.vehicle.trip.tripId)).font(.title).fontWeight(.bold)
                                    Text(RouteIdToName(routeId: train.vehicle.trip.routeId))
                                } else {
                                    VStack(alignment: .leading) {
                                        Text(FormatTripId(tripId: train.vehicle.trip.tripId)).font(.title).fontWeight(.bold)
                                        if !matching_trip_update[0].stopTimeUpdate.isEmpty {
                                            Text("\(RouteIdToName(routeId: train.vehicle.trip.routeId)) (\(GetStationFromStopId(stopID: Int(matching_trip_update[0].stopTimeUpdate.last?.stopId ?? "0") ?? 0).pretty_stop_name)) ").font(.system(size: 18))
                                        } else {
                                            Text(RouteIdToName(routeId: train.vehicle.trip.routeId)).font(.system(size: 18))
                                        }
                                        Text("Status: \(getStatus(train: train, updates: matching_trip_update[0]))")
                                    }
                                    Spacer()
                                    let late_threshold_sec = 60 * 3 // 3min
                                    let delay = matching_trip_update[0].stopTimeUpdate.last?.departure?.delay ?? 0
                                    let delay_min = Int(delay / 60)

                                    if delay > late_threshold_sec {
                                        HStack {
                                            Rectangle().frame(width: 12, height: 12, alignment: .center).foregroundColor(Color.red).cornerRadius(1000)
                                            Text("\(delay_min)m").monospaced()
                                        }
                                    } else {
                                        Rectangle().frame(width: 12, height: 12, alignment: .center).foregroundColor(Color.green).cornerRadius(1000)
                                        // Text("\(delay_min)m").monospaced() TMP
                                    }
                                }

                                Image(systemName: "arrow.right").padding(3)
                                    .font(.system(size: 24, weight: .light))
                            }
                        }.navigationLinkIndicatorVisibility(.hidden)
                    }
                }

            } else {
                Text("No Trains Found")
                Spacer()
            }
        }
        .alert("Please Donate", isPresented: $showDonateAlert) {
            Button {
                showDonateAlert = false
            } label: {
                Text("No Thanks.")
            }
            NavigationLink(destination: SettingsView()) {
                Button {} label: {
                    Text("Donate")
                }
            }

        } message: {
            Text("To keep MarcMap free and adless for all, please consider donating to help cover developmental costs. Any bit helps.")
        }
        .onAppear {
            Task {
                for await verificationResult in Transaction.updates {
                    UserDefaults.standard.set(verificationResult.jwsRepresentation, forKey: "purchaseJWT")
                }
            }
            let count = UserDefaults.standard.integer(forKey: "processCompletedCountKey")
            UserDefaults.standard.set(count + 1, forKey: "processCompletedCountKey")
            if count == 16 {
                Task { @MainActor in
                    requestReview()
                }
            }
            if count % 10 == 0 && (UserDefaults.standard.string(forKey: "purchaseJWT") == "" || UserDefaults.standard.string(forKey: "purchaseJWT") == nil) {
                showDonateAlert = true
            }
        }
    }
}
