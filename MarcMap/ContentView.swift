//
//  ContentView.swift
//  hello-world
//
//  Created by Quinn Patwardhan on 2/22/23.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    //1.

    init() {
        UITabBar.appearance().backgroundColor = UIColor.black
        UITabBar.appearance().unselectedItemTintColor = UIColor.gray
    }
    
    @State var trains = [Train]()
    var body: some View {
        
        if #available(iOS 16.0, *) {
            NavigationView {
            TabView {
                TrainsListView()
                    .tabItem {
                        Label("Trains", systemImage: "list.dash")
                    }
                FullScreenMap(tripId:"Null", trains:trains)
                    .tabItem {
                        Label("Map", systemImage: "map.fill")
                    }
                StationListView()
                    .tabItem {
                        Label("Stations", systemImage: "pin.circle.fill")
                    }
            }.onAppear() {
                apiCall().getTrains{(Trains) in
                    self.trains = Trains
                }
            }
        }.navigationBarTitleDisplayMode(.inline).padding(.top, -20).navigationViewStyle(StackNavigationViewStyle())
        } else {
            // Fallback on earlier versions
        }
      
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
