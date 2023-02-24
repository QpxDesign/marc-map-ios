//
//  TrainsListView.swift
//  hello-world
//
//  Created by Quinn Patwardhan on 2/22/23.
//


import Foundation
import SwiftUI

struct TrainsListView: View {
    //1.
    @State var trains = [Train]()
    
    var body: some View {
        NavigationView {
        VStack {
            HStack {
                Text("Trains").bold().multilineTextAlignment(.leading).padding(.leading,20).padding(.bottom, 15).foregroundColor(Color.white).font(.system(size: 34)).padding(.top,8)
            } .frame(maxWidth: .infinity, alignment: .leading).background(CustomColors.MarcOrange)
            List(trains) { train in
                VStack(alignment: .leading) {
                    HStack {
                        Text(FormatTripId(tripId: train.vehicle.trip.tripId))
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(RouteIdToName(routeId: train.vehicle.trip.routeId))
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

                    }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                }
                
                
            }
        }
            //2.
            .onAppear() {
                apiCall().getTrains { (trains) in
                    self.trains = trains
                }
            }
        }.navigationBarTitleDisplayMode(.inline).padding(.top, -20)
        
    }
}

