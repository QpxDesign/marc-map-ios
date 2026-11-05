//
//  TrainListItem.swift
//  MarcMap
//
//  Created by Quinn Patwardhan on 11/3/26.
//

import CoreLocation
import Foundation
import StoreKit
import SwiftUI

struct TrainListItem: View {
    let train: Train
    let trip_update: tripUpdate
    let stations: [station]
    let stopsAway: Int?
    let favorited: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    if favorited {
                        HStack {
                            Image(systemName: "star.fill").padding(0).font(.system(size: 23))
                            Text(FormatTripId(tripId: train.vehicle.trip.tripId)).font(.title).fontWeight(.bold)
                        }
                    } else {
                        Text(FormatTripId(tripId: train.vehicle.trip.tripId)).font(.title).fontWeight(.bold)
                    }
                    if stopsAway == nil {
                        Text("\(RouteIdToName(routeId: train.vehicle.trip.routeId))").font(.system(size: 18))
                    }
                }

                if stopsAway != nil {
                    let s = stopsAway.unsafelyUnwrapped
                    Text("\(RouteIdToName(routeId: train.vehicle.trip.routeId))").font(.system(size: 18))
                    Text("\(s) stop\(s > 1 ? "s" : "") away").monospaced()
                } else {
                    Text("Final Destination: \(GetStationFromStopId(stopID: Int(trip_update.stopTimeUpdate.last?.stopId ?? "0") ?? 0, stations: stations).pretty_stop_name)")
                    Text("Status: \(getStatus(train: train, updates: trip_update, stations: stations))")
                }
            }
            Spacer()
            let late_threshold_sec = 60 * 3
            let delay = max(0, GetDelay(updates: trip_update))
            let delay_min = Int(delay / 60)

            if delay > late_threshold_sec {
                HStack {
                    Rectangle().frame(width: 12, height: 12, alignment: .center).foregroundColor(Color.red).cornerRadius(1000)
                    Text("\(delay_min)m").monospaced()
                }
            } else {
                Rectangle().frame(width: 12, height: 12, alignment: .center).foregroundColor(Color.green).cornerRadius(1000)
            }

            Image(systemName: "arrow.right").padding(3)
                .font(.system(size: 32, weight: .light))

        }.frame(maxWidth: .infinity, alignment: .leading).multilineTextAlignment(.leading).foregroundStyle(Color.primary).padding(.leading, 20).padding(.trailing, 20) // .padding(.top, 5).padding(.bottom, 5)
    }
}

struct TrainList: View {
    @State var userLocation: CLLocation?
    let stations: [station]

    let manager = LocationManager()

    @ObservedObject var trainsViewModel: TrainsViewModel
    @ObservedObject var tripUpdatesViewModel: TripUpdatesViewModel
    let favoritesOnly: Bool?

    @State var sorted_trains: [Train] = []

    var body: some View {
        ForEach(sorted_trains) { train in
            VStack(alignment: .leading) {
                NavigationLink(destination: TrainDetailedView(tripId: train.vehicle.trip.tripId, stations: stations, trainsViewModel: trainsViewModel, tripUpdatesViewModel: tripUpdatesViewModel)) {
                    let matching_trip_update = tripUpdatesViewModel.tripUpdates.filter { $0.trip.tripId == train.vehicle.trip.tripId }
                    HStack {
                        if matching_trip_update.isEmpty {
                            Text(FormatTripId(tripId: train.vehicle.trip.tripId)).font(.title).fontWeight(.bold)
                            Text(RouteIdToName(routeId: train.vehicle.trip.routeId))
                        } else {
                            TrainListItem(train: train, trip_update: matching_trip_update[0], stations: stations, stopsAway: nil, favorited: favoritesOnly ?? false && !sorted_trains.isEmpty)
                        }

                    }.frame(maxWidth: .infinity, alignment: .leading)
                }.navigationLinkIndicatorVisibility(.hidden)
                Divider().frame(height: 1.25).background(Color.gray).cornerRadius(10).padding(.leading, 30).padding(.trailing, 30)
            }
        }.frame(maxWidth: .infinity, alignment: .leading).onAppear {
            manager.requestLocation()
            userLocation = manager.location
            sorted_trains = trainsViewModel.trains.sorted {
                let a1 = CLLocation(latitude: $0.vehicle.position.latitude, longitude: $0.vehicle.position.longitude)
                let d1 = a1.distance(from: userLocation ?? CLLocation(latitude: 38.9072, longitude: -77.0369))
                let a2 = CLLocation(latitude: $1.vehicle.position.latitude, longitude: $1.vehicle.position.longitude)
                let d2 = a2.distance(from: userLocation ?? CLLocation(latitude: 38.9072, longitude: -77.0369))
                return d1 < d2
            }
            let favs = getFavorites()
            if favoritesOnly != nil, favoritesOnly.unsafelyUnwrapped {
                sorted_trains = sorted_trains.filter { favs.contains($0.vehicle.trip.tripId) }
            } else if favoritesOnly != nil, !favoritesOnly.unsafelyUnwrapped {
                sorted_trains = sorted_trains.filter { !favs.contains($0.vehicle.trip.tripId) }
            }

        }.onReceive(trainsViewModel.$trains, perform: { trains in // update markers
            sorted_trains = trains.sorted {
                let a1 = CLLocation(latitude: $0.vehicle.position.latitude, longitude: $0.vehicle.position.longitude)
                let d1 = a1.distance(from: userLocation ?? CLLocation(latitude: 38.9072, longitude: -77.0369))
                let a2 = CLLocation(latitude: $1.vehicle.position.latitude, longitude: $1.vehicle.position.longitude)
                let d2 = a2.distance(from: userLocation ?? CLLocation(latitude: 38.9072, longitude: -77.0369))
                return d1 < d2
            }
            let favs = getFavorites()

            if favoritesOnly != nil, favoritesOnly.unsafelyUnwrapped {
                sorted_trains = sorted_trains.filter { favs.contains($0.vehicle.trip.tripId) }
            } else if favoritesOnly != nil, !favoritesOnly.unsafelyUnwrapped {
                sorted_trains = sorted_trains.filter { !favs.contains($0.vehicle.trip.tripId) }
            }

        })
    }
}
