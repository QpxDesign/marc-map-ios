//
//  TrainsListView.swift
//  hello-world
//
//  Created by Quinn Patwardhan on 2/22/23.
//


import Foundation
import SwiftUI
import WeatherKit
import CoreLocation

@available(iOS 16.0, *)
struct TrainsListView: View {
    //1.
    @State var trains = [Train]()
    @State var tripDetails = [tripUpdate]()
    @State var currentWeather : CurrentWeather?
    var body: some View {
        VStack {
            HeaderView(title:"Trains")
            if (!trains.isEmpty) {
                List(trains) { train  in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(FormatTripId(tripId: train.vehicle.trip.tripId))
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text(RouteIdToName(routeId: train.vehicle.trip.routeId))
                            if (!tripDetails.isEmpty && (tripDetails[0].stopTimeUpdate[0].departure?.delay ?? 0) > 300) {
                                Rectangle().frame(width: 10, height: 10, alignment: .center).foregroundColor(Color.red).cornerRadius(1000)
                            } else {
                                Rectangle().frame(width: 10, height: 10, alignment: .center).foregroundColor(Color.green).cornerRadius(1000)
                            }
                  
                            Spacer()
                            HStack(spacing: 0) {
                                Image(systemName: "arrow.right")
                                .font(.system(size: 24, weight: .light))

                                NavigationLink(destination: TrainDetailedView(tripId: train.vehicle.trip.tripId)) {
                                  EmptyView()
                                }
                                .frame(width: 0)
                                .opacity(0)
                              }

                        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading).accentColor(CustomColors.MarcBlue)
                    }
                }
            } else {
                
                Text("No Trains Found")
                Spacer()
            }
            
        }
            //2.
            .onAppear() {
                    apiCall().getTrains { (trains) in
                        self.trains = trains
                    }
                apiCall().getTripUpdates{(updates) in
                    self.tripDetails = updates
                }
            }
        
        
    }
}
