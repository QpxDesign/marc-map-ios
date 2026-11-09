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
    @ObservedObject var masterViewModel: MasterViewModel
    
    @State var data: CombinedTrainObject
    
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
    let stations = loadStations()
    
    @State var localFavState: Bool = false
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text(FormatTripId(tripId: data.trip_id)).bold().multilineTextAlignment(.leading).foregroundColor(Color.white).font(.system(size: 34))
                    if data.position.speed != nil {
                        let speed = data.position.speed?.rounded().description ?? ""
                                    
                        Text("\(speed)mph").foregroundColor(Color.white).font(.system(size: 18)).monospaced()
                    }
                    Spacer()
                    Image(systemName: localFavState ? "star.fill" : "star").font(.system(size: 28)).foregroundStyle(Color.white).onTapGesture {
                        toggleFavorite(favorite: data.trip_id)
                        localFavState = !localFavState
                    }
                }.frame(maxWidth: .infinity, alignment: .leading).padding(.bottom, 15).padding(.leading, 20).padding(.trailing, 20).background(CustomColors.MarcOrange).onAppear {
                    localFavState = !favorites.filter { $0 == data.trip_id }.isEmpty
                }
                            
                Text("Last Updated: " + FormatTime(timestamp: data.position_timestamp))
                let suppliedSpan = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                // NavigationLink(destination: FullScreenMap(stations: stations, trainsViewModel: trainsViewModel, tripUpdatesViewModel: tripUpdatesViewModel, suppliedLoc: CLLocationCoordinate2D(latitude: matching_train[0].vehicle.position.latitude, longitude: matching_train[0].vehicle.position.longitude), suppliedSpan: ))
                            
                NavigationLink(destination: FullScreenMap(stations: stations, masterViewModel: masterViewModel, suppliedLoc: CLLocationCoordinate2D(latitude: data.position.latitude, longitude: data.position.longitude), suppliedSpan: suppliedSpan)) {
                    EmbeddedMap(locationViewModel: LocationViewModel(supplied_loc: CLLocationCoordinate2D(latitude: data.position.latitude, longitude: data.position.longitude)), masterViewModel: masterViewModel, tripId: data.trip_id, suppliedSpan: suppliedSpan).frame(height: 200).allowsHitTesting(false)
                }
                            
                if !data.stopTimeUpdates.isEmpty {
                    let tD = data.stopTimeUpdates.filter { Double($0.departure?.time ?? "0") ?? 0 > NSDate().timeIntervalSince1970 || Double($0.arrival?.time ?? "0") ?? 0 > NSDate().timeIntervalSince1970 }
                    let tDa = data.stopTimeUpdates.filter { Double($0.departure?.time ?? "0") ?? 0 < NSDate().timeIntervalSince1970 || Double($0.arrival?.time ?? "0") ?? 0 < NSDate().timeIntervalSince1970 }
                    let t = removeDuplicates(arr: tD + tDa)
                    
                    VStack(alignment: .center) {
                        List(t) { stop in
                            let delta = NSDate().timeIntervalSince1970 + 30
                            let dep_time = Double(stop.departure?.time ?? "0") ?? 0
                            let arr_time = Double(stop.arrival?.time ?? "0") ?? 0
                            if dep_time > delta || arr_time > delta {
                                HStack {
                                    Text(GetStationFromStopId(stopID: Int(stop.stopId) ?? 0, stations: stations).pretty_stop_name)
                                    Spacer()
                                    Text(stop.arrival?.time != nil ? FormatTime(timestamp: stop.arrival?.time ?? "") : stop.departure?.time != nil ? FormatTime(timestamp: stop.departure?.time ?? "") : "Unknown").bold()
                                }
                                // removed navigation link to stations:    NavigationLink(destination: StationDetailedView(stationObj: GetStationFromStopId(stopID: Int(stop.stopId) ?? 0, stations: stations))) {
                            } else { // inactive stops
                                HStack {
                                    Text(GetStationFromStopId(stopID: Int(stop.stopId) ?? 0, stations: stations).stop_name).foregroundColor(Color.gray)
                                    Spacer()
                                    Text(stop.arrival?.time != nil ? FormatTime(timestamp: stop.arrival?.time ?? "0") : stop.departure?.time != nil ? FormatTime(timestamp: stop.departure?.time ?? "0") : "Unknown").bold().foregroundColor(Color.gray)
                                }
                            }
                        }.contentMargins(.top, 15)
                        HStack {
                            Text("Last Stop: " + GetStationFromStopId(stopID: Int(data.stopTimeUpdates.last?.stopId ?? "0") ?? 0, stations: stations).stop_name).foregroundColor(Color.white).padding(10).background(CustomColors.MarcBlue).bold().frame(maxWidth: .infinity).multilineTextAlignment(.center)
                                        
                        }.frame(maxWidth: .infinity, alignment: .center).font(.system(size: 18)).background(CustomColors.MarcBlue).padding(.horizontal, 10)
                    }.padding(.top, 0)
                                
                } else {
                    Text("Loading")
                }
                            
                Spacer()
            }
        }.onReceive(masterViewModel.$data, perform: { t in
            let d = t.filter { $0.trip_id == data.trip_id }
            if d.isEmpty {
                // TODO: - navigate home?
                
            } else {
                data = d[0]
            }
        
        })
    }
}

func removeDuplicates(arr: [stopTimeUpdate]) -> [stopTimeUpdate] {
    var a: [stopTimeUpdate] = []
    for i in arr {
        if (a.filter { $0.id == i.id }.count == 0) {
            a.append(i)
        }
    }
    return a
}

#Preview("Main") {
    ContentView()
}
