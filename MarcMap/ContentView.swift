//
//  ContentView.swift
//  hello-world
//
//  Created by Quinn Patwardhan on 2/22/23.
//

import CoreLocation
import SwiftUI

struct ContentView: View {
    // 1.

    /*
     init() {
         UITabBar.appearance().backgroundColor = UIColor.white
         UITabBar.appearance().unselectedItemTintColor = UIColor.gray
     }*/

    @ObservedObject private var trainsViewModel = TrainsViewModel()
    @ObservedObject private var tripUpdatesViewModel = TripUpdatesViewModel()

    var body: some View {
        NavigationView {
            TabView {
                TrainsListView(trainsViewModel: trainsViewModel, tripUpdatesViewModel: tripUpdatesViewModel)
                    .tabItem {
                        Label("Trains", systemImage: "list.dash").accentColor(.white)
                    }
                FullScreenMap(trainsViewModel: trainsViewModel, tripUpdatesViewModel: tripUpdatesViewModel)
                    .tabItem {
                        Label("Map", systemImage: "map.fill").accentColor(.white).background(Color.white).foregroundColor(Color.white)
                    }
                StationListView(trainsViewModel: trainsViewModel, tripUpdatesViewModel: tripUpdatesViewModel)
                    .tabItem {
                        Label("Stations", systemImage: "pin.circle.fill").accentColor(.white).background(Color.white).foregroundColor(Color.white)
                    }
                SettingsView()
                    .tabItem {
                        Label("Info", systemImage: "info.circle.fill").accentColor(.white).background(Color.white).foregroundColor(Color.white)
                    }
            }
        }.navigationBarTitleDisplayMode(.inline).padding(.top, -20).navigationViewStyle(StackNavigationViewStyle()).accentColor(.black)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
            ContentView()
        }
    }
}
