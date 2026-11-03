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
    
    @StateObject private var trainsViewModel = TrainsViewModel()
    @StateObject private var tripUpdatesViewModel = TripUpdatesViewModel()
    /// @State var details = [Train]()
    /// @State var tripDetails = [tripUpdate]()
    @State var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 38.9072, longitude: -77.0369),
        latitudinalMeters: 15000,
        longitudinalMeters: 15000
    )
    let brunswick: [CLLocationCoordinate2D] = getRouteFromFile(filename: "Brunswick") ?? [CLLocationCoordinate2D(latitude: 0, longitude: 0)]
    let penn: [CLLocationCoordinate2D] = getRouteFromFile(filename: "Penn") ?? [CLLocationCoordinate2D(latitude: 0, longitude: 0)]
    let fred: [CLLocationCoordinate2D] = getRouteFromFile(filename: "FredrickBranch") ?? [CLLocationCoordinate2D(latitude: 0, longitude: 0)]
    let camd: [CLLocationCoordinate2D] = getRouteFromFile(filename: "Camden") ?? [CLLocationCoordinate2D(latitude: 0, longitude: 0)]
    
    var body: some View {
        if trainsViewModel.isLoading || tripUpdatesViewModel.isLoading {
            HStack {
                Text("Loading...").bold().multilineTextAlignment(.leading).padding(.leading, 20).padding(.bottom, 15).foregroundColor(Color.white).font(.system(size: 34))
                Spacer()
                
            }.frame(maxWidth: .infinity, alignment: .leading).background(CustomColors.MarcOrange)
            Spacer()
            
        } else {
            GeometryReader {
                _ in
                let matching_trip_update = tripUpdatesViewModel.tripUpdates.filter { $0.trip.tripId == tripId }
                let matching_train = trainsViewModel.trains.filter { $0.vehicle.trip.tripId == tripId }
                if matching_trip_update.isEmpty || matching_train.isEmpty {
                    TrainsListView()
                } else {
                    VStack {
                        HStack {
                            Text(FormatTripId(tripId: tripId)).bold().multilineTextAlignment(.leading).padding(.leading, 20).padding(.bottom, 15).foregroundColor(Color.white).font(.system(size: 34))
                        }.frame(maxWidth: .infinity, alignment: .leading).background(CustomColors.MarcOrange)
                     
                        Text("Last Updated: " + FormatTime(timestamp: matching_train[0].vehicle.timestamp))
                        NavigationLink(destination: FullScreenMap(suppliedLoc: CLLocationCoordinate2D(latitude: matching_train[0].vehicle.position.latitude, longitude: matching_train[0].vehicle.position.longitude), suppliedSpan: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))) {
                            EmbeddedMap(loc: CLLocationCoordinate2D(latitude: matching_train[0].vehicle.position.latitude, longitude: matching_train[0].vehicle.position.longitude), tripId: matching_train[0].vehicle.trip.tripId)
                            // region: region, BrunswickLineCoordinates: brunswick, PennLineCoordinates: penn, CamdenLineCoordinates: camd, FredrickBranchLineCoordinates: fred, tripId: tripId).frame(width: geometry.size.width * 0.90, height: geometry.size.height * 0.35).cornerRadius(15).padding(.bottom, 0
                        }.accentColor(Color.black)
                    
                        if !matching_trip_update[0].stopTimeUpdate.isEmpty {
                            let tD = matching_trip_update[0].stopTimeUpdate.filter { Double($0.departure?.time ?? "0") ?? 0 > NSDate().timeIntervalSince1970 || Double($0.arrival?.time ?? "0") ?? 0 > NSDate().timeIntervalSince1970 }
                            let tDa = matching_trip_update[0].stopTimeUpdate.filter { Double($0.departure?.time ?? "0") ?? 0 < NSDate().timeIntervalSince1970 || Double($0.arrival?.time ?? "0") ?? 0 < NSDate().timeIntervalSince1970 }
                            let t = removeDuplicates(arr: tD + tDa)
                            VStack(alignment: .trailing) {
                                List(t) { stop in
                                    HStack {
                                        if Double(stop.departure?.time ?? "0") ?? 0 > NSDate().timeIntervalSince1970 + 30 || Double(stop.arrival?.time ?? "0") ?? 0 > NSDate().timeIntervalSince1970 + 30 {
                                            Text(GetStationFromStopId(stopID: Int(stop.stopId) ?? 0).stop_name)
                                            Spacer()
                                            Text(stop.arrival?.time != nil ? FormatTime(timestamp: stop.arrival?.time ?? "") : stop.departure?.time != nil ? FormatTime(timestamp: stop.departure?.time ?? "") : "Unknown").bold()
                                        } else {
                                            Text(GetStationFromStopId(stopID: Int(stop.stopId) ?? 0).stop_name).foregroundColor(Color.gray)
                                            Spacer()
                                            Text(stop.arrival?.time != nil ? FormatTime(timestamp: stop.arrival?.time ?? "0") : stop.departure?.time != nil ? FormatTime(timestamp: stop.departure?.time ?? "0") : "Unknown").bold().foregroundColor(Color.gray)
                                        }
                                    }
                                    //  }
                                }
                                HStack {
                                    Text("Last Stop: " + GetStationFromStopId(stopID: Int(matching_trip_update[0].stopTimeUpdate.last?.stopId ?? "0") ?? 0).stop_name).foregroundColor(Color.white).padding(10).background(CustomColors.MarcBlue).bold().frame(maxWidth: .infinity)
                                
                                }.frame(maxWidth: .infinity, alignment: .center).font(.system(size: 18)).background(CustomColors.MarcBlue).padding(.horizontal, 10)
                            }.frame(alignment: .leading).padding(.top, 0)
                            
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
