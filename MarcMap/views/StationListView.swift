//
//  StationListView.swift
//  MarcMap
//
//  Created by Quinn Patwardhan on 2/26/23.
//

import SwiftUI
import WeatherKit
import CoreLocation

@available(iOS 16.0, *)
struct StationListView: View {
    @State var currentWeather : CurrentWeather?
    @State var userLocation: CLLocation?
    @State var stations : [station] = getStations()
    
    let manager = LocationManager()
    var body: some View {
        VStack {
            HStack {
                Text("Stations").bold().multilineTextAlignment(.leading).padding(.leading,20).padding(.bottom, 15).foregroundColor(Color.white).font(.system(size: 34)).padding(.top,8).onAppear() {
                    Task {
                        self.currentWeather =  await getWeather()
                    }
                }.onAppear() {
                    manager.requestLocation()
                    userLocation = manager.location
                    stations.sort() {
                        var a1 = CLLocation(latitude: $0.stop_lat, longitude: $0.stop_lon)
                        var d1 = a1.distance(from: userLocation ?? CLLocation(latitude: 0, longitude: 0))
                         var a2 = CLLocation(latitude: $0.stop_lat, longitude: $1.stop_lon)
                         var d2 = a2.distance(from: userLocation ?? CLLocation(latitude: 0, longitude: 0))
                        return d1 < d2
                        
                    }
         
                }
                Spacer()
                HStack {
                    Image(systemName: ((currentWeather?.symbolName ?? "icloud.slash") + ".fill") ?? "icloud.slash").foregroundColor(Color.white)
                    Text(String(Int(floor(CelciusToFahrenheit(C: currentWeather?.apparentTemperature.value ?? 0))))+"° F").bold().font(.system(size: 20)).foregroundColor(Color.white)
                }.padding(.trailing,25)
                
                
                
                
            } .frame(maxWidth: .infinity, alignment: .leading).background(CustomColors.MarcOrange)
            if (!stations.isEmpty) {
                List(stations) { station  in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(station.stop_name).bold().font(.system(size: 20
                                                                       ))
                            Spacer()
                            Text(String(getDistanceToStation(stop_lat: station.stop_lat, stop_lon: station.stop_lon, userLocation: userLocation)) + " miles")
                            HStack(spacing: 0) {
                                Image(systemName: "arrow.right")
                                .font(.system(size: 24, weight: .light))

                                NavigationLink(destination: StationDetailedView(stationObj: station)) {
                                  EmptyView()
                                }
                                .frame(width: 0)
                                .opacity(0)
                              }
                        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading).accentColor(CustomColors.MarcBlue)
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

func getDistanceToStation(stop_lat : Double, stop_lon : Double,userLocation : CLLocation?) -> Double {
    var a1 = CLLocation(latitude: stop_lat, longitude: stop_lon)
    var d1 = a1.distance(from: userLocation ?? CLLocation(latitude: 0, longitude: 0))
    d1 = d1/1000 //M TO KM
    d1 = d1/1.609 // KM TO MILES
    d1 = round(d1 * 100)/100.0
    return d1
}
