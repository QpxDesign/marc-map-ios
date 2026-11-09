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

struct TrainListItem: View, Equatable {
    @ObservedObject var masterViewModel: MasterViewModel

    @State var train: CombinedTrainObject
    let stopsAway: Int?
    let favorited: Bool

    let stations: [station] = loadStations()

    static func == (lhs: TrainListItem, rhs: TrainListItem) -> Bool {
        lhs.train.position_timestamp == rhs.train.position_timestamp && lhs.train.stopupdate_timestamp == rhs.train.stopupdate_timestamp
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    if favorited {
                        HStack {
                            Image(systemName: "star.fill").padding(0).font(.system(size: 23))
                            Text(FormatTripId(tripId: train.trip_id)).font(.title).fontWeight(.bold)
                        }
                    } else {
                        Text(FormatTripId(tripId: train.trip_id)).font(.title).fontWeight(.bold)
                    }
                    if stopsAway == nil {
                        Text("\(RouteIdToName(routeId: train.route_id))").font(.system(size: 18))
                    }
                }

                if stopsAway != nil {
                    let s = stopsAway.unsafelyUnwrapped
                    Text("\(RouteIdToName(routeId: train.route_id))").font(.system(size: 18))
                    if s == 0 {
                        Text("Next Stop").monospaced()

                    } else {
                        Text("\(s) stop\(s > 1 ? "s" : "") away").monospaced()
                    }
                } else {
                    Text("\(getStatus(data: train, stations: stations))")
                    Text("Final Destination: \(GetStationFromStopId(stopID: Int(train.stopTimeUpdates.last?.stopId ?? "0") ?? 0, stations: stations).pretty_stop_name)")
                }
            }
            Spacer()
            let late_threshold_sec = 60 * 3
            let delay = max(0, GetDelay(data: train))
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

        }.onReceive(masterViewModel.$data, perform: { d in
            let f = d.filter { $0.trip_id == train.trip_id }
            if !f.isEmpty {
                train = f[0]
            }

        }).frame(maxWidth: .infinity, alignment: .leading).multilineTextAlignment(.leading).foregroundStyle(Color.primary).padding(.leading, 20).padding(.trailing, 20)
    }
}

struct TrainList: View, Equatable {
    @State var userLocation: CLLocation?

    let manager = LocationManager()

    @ObservedObject var masterViewModel: MasterViewModel

    let favoritesOnly: Bool?

    @State var sorted_data: [CombinedTrainObject] = []

    static func == (lhs: TrainList, rhs: TrainList) -> Bool {
        lhs.sorted_data == rhs.sorted_data
    }

    func update() {
        sorted_data = masterViewModel.data.sorted {
            let a1 = CLLocation(latitude: $0.position.latitude, longitude: $0.position.longitude)
            let d1 = a1.distance(from: userLocation ?? CLLocation(latitude: 38.9072, longitude: -77.0369))
            let a2 = CLLocation(latitude: $1.position.latitude, longitude: $1.position.longitude)
            let d2 = a2.distance(from: userLocation ?? CLLocation(latitude: 38.9072, longitude: -77.0369))
            return d1 < d2
        }
        let favs = getFavorites()
        if favoritesOnly != nil, favoritesOnly.unsafelyUnwrapped {
            sorted_data = masterViewModel.data.filter { favs.contains($0.trip_id) }
        } else if favoritesOnly != nil, !favoritesOnly.unsafelyUnwrapped {
            sorted_data = masterViewModel.data.filter { !favs.contains($0.trip_id) }
        }
    }

    var body: some View {
        VStack {
            ForEach(sorted_data) { train in
                VStack(alignment: .leading) {
                    NavigationLink(destination: TrainDetailedView(masterViewModel: masterViewModel, data: train)) {
                        HStack {
                            TrainListItem(masterViewModel: masterViewModel, train: train, stopsAway: nil, favorited: favoritesOnly ?? false && !sorted_data.isEmpty).equatable()

                        }.frame(maxWidth: .infinity, alignment: .leading)

                    }.navigationLinkIndicatorVisibility(.hidden)
                    Divider().frame(height: 1.25).background(Color.gray).cornerRadius(10).padding(.leading, 30).padding(.trailing, 30)
                }
            }.frame(maxWidth: .infinity, alignment: .leading).onAppear {
                manager.requestLocation()
                userLocation = manager.location
                update()
            }
        }.onReceive(masterViewModel.$data, perform: { _ in // update markers
            update()

        })
    }
}
