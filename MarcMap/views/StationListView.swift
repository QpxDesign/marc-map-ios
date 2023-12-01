//
//  StationListView.swift
//  MarcMap
//
//  Created by Quinn Patwardhan on 2/26/23.
//

import SwiftUI
import CoreLocation

@available(iOS 16.0, *)
struct StationListView: View {
    @State var userLocation: CLLocation?
    @State var stations : [station] = getStations()

   let manager = LocationManager()
    var body: some View {
        VStack {
            HeaderView(title:"Stations").onAppear() {
                manager.requestLocation()
                userLocation = manager.location
          
                stations.sort() {
                    let a1 = CLLocation(latitude: $0.stop_lat, longitude: $0.stop_lon)
                    let d1 = a1.distance(from: userLocation ?? CLLocation(latitude: 38.9072, longitude: -77.0369))
                    let a2 = CLLocation(latitude: $1.stop_lat, longitude: $1.stop_lon)
                    let d2 = a2.distance(from: userLocation ?? CLLocation(latitude: 38.9072, longitude: -77.0369))
                    return d1 < d2
                }
     
            }
            if (!stations.isEmpty) {
                List(stations) { station  in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(station.stop_name).bold().font(.system(size: 20))
                            Spacer()
                            Text(getDistanceToStation(stop_lat: station.stop_lat, stop_lon: station.stop_lon, userLocation: userLocation))
                            HStack(spacing: 0) {
                                Image(systemName: "arrow.right")
                                .font(.system(size: 24, weight: .light))
                                if #available(iOS 17.0, *) {
                                    NavigationLink(destination: NewStationDetailedView(stationObj: station, dateInput: Date())) {
                                        EmptyView()
                                    }.accentColor(Color.black)
                                    .frame(width: 0)
                                    .opacity(0)
                                } else if #available(iOS 16.0, *) {
                                    NavigationLink(destination: StationDetailedView(stationObj: station, dateInput: Date())) {
                                        EmptyView()
                                    }.accentColor(Color.black)
                                    .frame(width: 0)
                                    .opacity(0)
                                }
                              }
                        }
                       
                    }
                    
                }
            }
        }
  
    }
   
}

struct StationListView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 16.0, *) {
            StationListView()
        } else {
            // Fallback on earlier versions
        }
    }
}

func getDistanceToStation(stop_lat : Double, stop_lon : Double, userLocation : CLLocation?) -> String {
    var a1 = CLLocation(latitude: stop_lat, longitude: stop_lon)
    var d1 = a1.distance(from: userLocation ?? CLLocation(latitude: 0, longitude: 0))
    if (userLocation == nil) {
        return "n/a"
    }
    d1 = d1/1000 //M TO KM
    d1 = d1/1.609 // KM TO MILES
    d1 = round(d1 * 100)/100.0
    var ans = String(d1) + " miles"
    return ans
}
