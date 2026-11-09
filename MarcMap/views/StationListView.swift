//
//  StationListView.swift
//  MarcMap
//
//  Created by Quinn Patwardhan on 2/26/23.
//

import CoreLocation
import SwiftUI

struct StationList: View {
    @StateObject var masterViewModel: MasterViewModel
    @State var userLocation: CLLocation?

    @State var sorted_stations: [station] = []
    let manager = LocationManager()

    var body: some View {
        VStack {
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
                                NavigationLink(destination: StationDetailedView(stationObj: station, masterViewModel: masterViewModel, dateInput: Date())) {
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
            sorted_stations = masterViewModel.stations.sorted { // TODO: remove stations from view model (to avoid reloading this whenever trains/tripupdates changes, as stations should be static
                let a1 = CLLocation(latitude: $0.stop_lat, longitude: $0.stop_lon)
                let d1 = a1.distance(from: userLocation ?? CLLocation(latitude: 38.9072, longitude: -77.0369))
                let a2 = CLLocation(latitude: $1.stop_lat, longitude: $1.stop_lon)
                let d2 = a2.distance(from: userLocation ?? CLLocation(latitude: 38.9072, longitude: -77.0369))
                return d1 < d2
            }
        }
    }
}

struct StationListView: View {
    @StateObject var masterViewModel: MasterViewModel

    var body: some View {
        VStack {
            HeaderView(title: "Stations", headerViewModel: masterViewModel.headerViewModel)
            StationList(masterViewModel: masterViewModel)
            Spacer()
        }
    }
}

func getDistanceToStation(stop_lat: Double, stop_lon: Double, userLocation: CLLocation?) -> String {
    let a1 = CLLocation(latitude: stop_lat, longitude: stop_lon)
    var d1 = a1.distance(from: userLocation ?? CLLocation(latitude: 38.9072, longitude: -77.0369))
    if userLocation == nil {
        return ""
    }
    d1 = d1/1000 // M TO KM
    d1 = d1/1.609 // KM TO MILES
    d1 = round(d1 * 100)/100.0
    return String(d1) + " miles"
}

#Preview("Stations Only") {
    ContentView()
}
