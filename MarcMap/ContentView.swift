//
//  ContentView.swift
//  hello-world
//
//  Created by Quinn Patwardhan on 2/22/23.
//

import CoreLocation
import MapKit
import SwiftUI

struct ContentView: View {
    // 1.

    /*
     init() {
         UITabBar.appearance().backgroundColor = UIColor.white
         UITabBar.appearance().unselectedItemTintColor = UIColor.gray
     }*/

    @StateObject var masterViewModel = MasterViewModel()

    private let stations = loadStations()
    @State private var position: MapCameraPosition = .region(MKCoordinateRegion(center: .init(latitude: 38.9072, longitude: -77.0369), span: .init(latitudeDelta: 0.25, longitudeDelta: 0.25)))
    @Namespace var mapScope

    var body: some View {
        NavigationView {
            TabView {
                TrainsListView(masterViewModel: masterViewModel)
                    .tabItem {
                        Label("Trains", systemImage: "list.dash").accentColor(.white)
                    }

                FullScreenMap(stations: stations, masterViewModel: masterViewModel)
                    .tabItem {
                        Label("Map", systemImage: "map.fill").accentColor(.white).background(Color.white).foregroundColor(Color.white)
                    }

                StationListView(masterViewModel: masterViewModel)
                    .tabItem {
                        Label("Stations", systemImage: "pin.circle.fill").accentColor(.white).background(Color.white).foregroundColor(Color.white)
                    }
                SettingsView(headerViewModel: masterViewModel.headerViewModel)
                    .tabItem {
                        Label("Info", systemImage: "info.circle.fill").accentColor(.white).background(Color.white).foregroundColor(Color.white)
                    }
            }
        }.navigationBarTitleDisplayMode(.inline).navigationViewStyle(StackNavigationViewStyle()) // .padding(.top, -20) */
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}

/*
 NavigationStack {
     List(masterViewModel.data) { d in
         NavigationLink(d.trip_id, value: d)
     }
 }.navigationDestination(for: CombinedTrainObject.self) { cto in
     TrainDetailedView(data: cto)
 }
 */
