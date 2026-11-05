//
//  TrainDetailedView.swift
//  hello-world
//
//  Created by Quinn Patwardhan on 2/22/23.
//
import Foundation
import MapKit
import SwiftUI

struct TrainDetailedView: View {
    var tripId: String
    let stations: [station]
    
    @ObservedObject var trainsViewModel: TrainsViewModel
    @ObservedObject var tripUpdatesViewModel: TripUpdatesViewModel
    
    @State var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 38.9072, longitude: -77.0369),
        latitudinalMeters: 15000,
        longitudinalMeters: 15000
    )
    
    let favorites = getFavorites()
    let brunswick: [CLLocationCoordinate2D] = getRouteFromFile(filename: "Brunswick") ?? [CLLocationCoordinate2D(latitude: 0, longitude: 0)]
    let penn: [CLLocationCoordinate2D] = getRouteFromFile(filename: "Penn") ?? [CLLocationCoordinate2D(latitude: 0, longitude: 0)]
    let fred: [CLLocationCoordinate2D] = getRouteFromFile(filename: "FredrickBranch") ?? [CLLocationCoordinate2D(latitude: 0, longitude: 0)]
    let camd: [CLLocationCoordinate2D] = getRouteFromFile(filename: "Camden") ?? [CLLocationCoordinate2D(latitude: 0, longitude: 0)]
    
    @State var localFavState: Bool = false
    var body: some View {
        let matching_trip_update = tripUpdatesViewModel.tripUpdates.filter { $0.trip.tripId == tripId }
        let matching_train = trainsViewModel.trains.filter { $0.vehicle.trip.tripId == tripId }

        if (matching_trip_update.isEmpty || matching_train.isEmpty) && (trainsViewModel.isLoading || tripUpdatesViewModel.isLoading) {
            HStack {
                Text("Loading...").bold().multilineTextAlignment(.leading).padding(.leading, 20).padding(.bottom, 15).foregroundColor(Color.white).font(.system(size: 34))
                Spacer()
                
            }.frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 15).background(CustomColors.MarcOrange)
            Spacer()
            
        } else {
            GeometryReader {
                _ in
                if matching_trip_update.isEmpty || matching_train.isEmpty {
                    TrainsListView(stations: stations, trainsViewModel: trainsViewModel, tripUpdatesViewModel: tripUpdatesViewModel)
                } else {
                    VStack {
                        HStack {
                            Text(FormatTripId(tripId: tripId)).bold().multilineTextAlignment(.leading).foregroundColor(Color.white).font(.system(size: 34))
                            if matching_train[0].vehicle.position.speed != nil {
                                let speed = matching_train[0].vehicle.position.speed?.rounded().description ?? ""
                            
                                Text("\(speed)mph").foregroundColor(Color.white).font(.system(size: 18)).monospaced()
                            }
                            Spacer()
                            Image(systemName: localFavState ? "star.fill" : "star").font(.system(size: 28)).foregroundStyle(Color.white).onTapGesture {
                                toggleFavorite(favorite: tripId)
                                localFavState = !localFavState
                            }
                        }.frame(maxWidth: .infinity, alignment: .leading).padding(.bottom, 15).padding(.leading, 20).padding(.trailing, 20).background(CustomColors.MarcOrange).onAppear {
                            localFavState = !favorites.filter { $0 == tripId }.isEmpty
                        }
                     
                        Text("Last Updated: " + FormatTime(timestamp: matching_train[0].vehicle.timestamp))
                        // NavigationLink(destination: FullScreenMap(stations: stations, trainsViewModel: trainsViewModel, tripUpdatesViewModel: tripUpdatesViewModel, suppliedLoc: CLLocationCoordinate2D(latitude: matching_train[0].vehicle.position.latitude, longitude: matching_train[0].vehicle.position.longitude), suppliedSpan: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))
                         
                        EmbeddedMap(loc: CLLocationCoordinate2D(latitude: matching_train[0].vehicle.position.latitude, longitude: matching_train[0].vehicle.position.longitude), tripId: matching_train[0].vehicle.trip.tripId, stations: stations, trainsViewModel: trainsViewModel, tripUpdatesViewModel: tripUpdatesViewModel).frame(height: 200).allowsHitTesting(false)
     
                        if !matching_trip_update[0].stopTimeUpdate.isEmpty {
                            let tD = matching_trip_update[0].stopTimeUpdate.filter { Double($0.departure?.time ?? "0") ?? 0 > NSDate().timeIntervalSince1970 || Double($0.arrival?.time ?? "0") ?? 0 > NSDate().timeIntervalSince1970 }
                            let tDa = matching_trip_update[0].stopTimeUpdate.filter { Double($0.departure?.time ?? "0") ?? 0 < NSDate().timeIntervalSince1970 || Double($0.arrival?.time ?? "0") ?? 0 < NSDate().timeIntervalSince1970 }
                            let t = removeDuplicates(arr: tD + tDa)
                            VStack(alignment: .center) {
                                List(t) { stop in
                                    let delta = NSDate().timeIntervalSince1970 + 30
                                    let dep_time = Double(stop.departure?.time ?? "0") ?? 0
                                    let arr_time = Double(stop.arrival?.time ?? "0") ?? 0
                                    if dep_time > delta || arr_time > delta {
                                        NavigationLink(destination: StationDetailedView(stationObj: GetStationFromStopId(stopID: Int(stop.stopId) ?? 0, stations: stations), stations: stations, trainsViewModel: trainsViewModel, tripUpdatesViewModel: tripUpdatesViewModel)) {
                                            HStack {
                                                Text(GetStationFromStopId(stopID: Int(stop.stopId) ?? 0, stations: stations).stop_name)
                                                Spacer()
                                                Text(stop.arrival?.time != nil ? FormatTime(timestamp: stop.arrival?.time ?? "") : stop.departure?.time != nil ? FormatTime(timestamp: stop.departure?.time ?? "") : "Unknown").bold()
                                            }
                                        }
                                    } else { // inactive stops
                                        HStack {
                                            Text(GetStationFromStopId(stopID: Int(stop.stopId) ?? 0, stations: stations).stop_name).foregroundColor(Color.gray)
                                            Spacer()
                                            Text(stop.arrival?.time != nil ? FormatTime(timestamp: stop.arrival?.time ?? "0") : stop.departure?.time != nil ? FormatTime(timestamp: stop.departure?.time ?? "0") : "Unknown").bold().foregroundColor(Color.gray)
                                        }
                                    }
                                }.contentMargins(.top, 15)
                                HStack {
                                    Text("Last Stop: " + GetStationFromStopId(stopID: Int(matching_trip_update[0].stopTimeUpdate.last?.stopId ?? "0") ?? 0, stations: stations).stop_name).foregroundColor(Color.white).padding(10).background(CustomColors.MarcBlue).bold().frame(maxWidth: .infinity).multilineTextAlignment(.center)
                                
                                }.frame(maxWidth: .infinity, alignment: .center).font(.system(size: 18)).background(CustomColors.MarcBlue).padding(.horizontal, 10)
                            }.padding(.top, 0)
                            
                        } else {
                            Text("Loading")
                        }
                        
                        Spacer()
                    }
                }
            }
        }
    }
}

func removeDuplicates(arr: [stopTimeUpdate]) -> [stopTimeUpdate] {
    var a: [stopTimeUpdate] = []
    for i in arr {
        if (a.filter { $0.id.uuidString == i.id.uuidString }.count == 0) {
            a.append(i)
        }
    }
    return a
}
