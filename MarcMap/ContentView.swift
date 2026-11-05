//
//  ContentView.swift
//  hello-world
//
//  Created by Quinn Patwardhan on 2/22/23.
//

import CoreLocation
import SwiftUI

func loadStations() -> [station] {
    var stations: [station] = []
    if let url = Bundle.main.url(forResource: "StopDataPretty", withExtension: "json") {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let jsonData = try decoder.decode([station].self, from: data)

            for i in jsonData {
                stations.append(i)
            }

        } catch {
            print("error:\(error)")
        }
    }
    return stations
}

struct ContentView: View {
    // 1.

    /*
     init() {
         UITabBar.appearance().backgroundColor = UIColor.white
         UITabBar.appearance().unselectedItemTintColor = UIColor.gray
     }*/

    @ObservedObject private var trainsViewModel = TrainsViewModel()
    @ObservedObject private var tripUpdatesViewModel = TripUpdatesViewModel()
    var stations = loadStations()

    var body: some View {
        NavigationView {
            TabView {
                TrainsListView(stations: stations, trainsViewModel: trainsViewModel, tripUpdatesViewModel: tripUpdatesViewModel)
                    .tabItem {
                        Label("Trains", systemImage: "list.dash").accentColor(.white)
                    }
                FullScreenMap(stations: stations, trainsViewModel: trainsViewModel, tripUpdatesViewModel: tripUpdatesViewModel)
                    .tabItem {
                        Label("Map", systemImage: "map.fill").accentColor(.white).background(Color.white).foregroundColor(Color.white)
                    }
                StationListView(trainsViewModel: trainsViewModel, tripUpdatesViewModel: tripUpdatesViewModel, stations: stations)
                    .tabItem {
                        Label("Stations", systemImage: "pin.circle.fill").accentColor(.white).background(Color.white).foregroundColor(Color.white)
                    }
                SettingsView()
                    .tabItem {
                        Label("Info", systemImage: "info.circle.fill").accentColor(.white).background(Color.white).foregroundColor(Color.white)
                    }
            }
        }.navigationBarTitleDisplayMode(.inline).padding(.top, -20).navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}
