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

    init() {
        UITabBar.appearance().backgroundColor = UIColor.white
        UITabBar.appearance().unselectedItemTintColor = UIColor.gray
    }

    @State var trains = [Train]()
    var body: some View {
        NavigationView {
            TabView {
                TrainsListView()
                    .tabItem {
                        Label("Trains", systemImage: "list.dash").accentColor(.white)
                    }
                FullScreenMap()
                    .tabItem {
                        Label("Map", systemImage: "map.fill").accentColor(.white).background(Color.white).foregroundColor(Color.white)
                    }
                StationListView()
                    .tabItem {
                        Label("Stations", systemImage: "pin.circle.fill").accentColor(.white).background(Color.white).foregroundColor(Color.white)
                    }
                SettingsView()
                    .tabItem {
                        Label("Info", systemImage: "info.circle.fill").accentColor(.white).background(Color.white).foregroundColor(Color.white)
                    }

            }.onAppear {
                apiCall().getTrains { Trains in
                    self.trains = Trains ?? []
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
