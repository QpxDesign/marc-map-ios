//
//  StationListView.swift
//  MarcMap
//
//  Created by Quinn Patwardhan on 2/26/23.
//

import CoreLocation
import SwiftUI

struct StationListView: View {
    @State var userLocation: CLLocation?
    @ObservedObject var trainsViewModel: TrainsViewModel
    @ObservedObject var tripUpdatesViewModel: TripUpdatesViewModel
    var stations: [station]
    @State var sorted_stations: [station] = []

    let manager = LocationManager()
    var body: some View {
        VStack(alignment: .leading) {
            HeaderView(title: "Stations")
            Spacer()

            if !sorted_stations.isEmpty {
                List(sorted_stations) { station in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(station.pretty_stop_name).bold().font(.system(size: 20))
                            Spacer()
                            Text(getDistanceToStation(stop_lat: station.stop_lat, stop_lon: station.stop_lon, userLocation: userLocation))
                            HStack(spacing: 0) {
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 24, weight: .light))
                                NavigationLink(destination: StationDetailedView(stationObj: station, stations: stations, trainsViewModel: trainsViewModel, tripUpdatesViewModel: tripUpdatesViewModel, dateInput: Date())) {
                                    EmptyView()
                                }.accentColor(Color.black)
                                    .frame(width: 0)
                                    .opacity(0)
                            }
                        }
                    }
                }.contentMargins(.top, 10)
            }
        }.onAppear {
            manager.requestLocation()
            userLocation = manager.location
            sorted_stations = stations.sorted { // TODO: add sorted_stations
                let a1 = CLLocation(latitude: $0.stop_lat, longitude: $0.stop_lon)
                let d1 = a1.distance(from: userLocation ?? CLLocation(latitude: 38.9072, longitude: -77.0369))
                let a2 = CLLocation(latitude: $1.stop_lat, longitude: $1.stop_lon)
                let d2 = a2.distance(from: userLocation ?? CLLocation(latitude: 38.9072, longitude: -77.0369))
                return d1 < d2
            }
        }
    }
}

func getDistanceToStation(stop_lat: Double, stop_lon: Double, userLocation: CLLocation?) -> String {
    let a1 = CLLocation(latitude: stop_lat, longitude: stop_lon)
    var d1 = a1.distance(from: userLocation ?? CLLocation(latitude: 0, longitude: 0))
    if userLocation == nil {
        return "n/a"
    }
    d1 = d1/1000 // M TO KM
    d1 = d1/1.609 // KM TO MILES
    d1 = round(d1 * 100)/100.0
    return String(d1) + " miles"
}

#Preview("Stations Only") {
    ContentView()
}
