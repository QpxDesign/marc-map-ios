//
//  TrainsListView.swift
//  hello-world
//
//  Created by Quinn Patwardhan on 2/22/23.
//


import Foundation
import SwiftUI
import CoreLocation
import StoreKit

@available(iOS 16.0, *)
struct TrainsListView: View {
    //1.
    
    @State var trains = [Train]()
    @State var tripDetails = [tripUpdate]()
    @State var activeTrainId = ""
    @State var trainShowed : [Bool] = []
    var timer = Timer()
    var body: some View {
        VStack {
            HeaderView(title:"Trains")
            if (!trains.isEmpty) {
                
                List(trains.indices,id: \.self) { i  in
                    if (!trainShowed.isEmpty && trainShowed.count == trains.count) {
                        VStack(alignment: .leading) {
                            HStack {
                                Text(FormatTripId(tripId: trains[i].vehicle.trip.tripId))
                                    .font(.title)
                                    .fontWeight(.bold).onAppear() {
                                        self.activeTrainId = ""
                                        print("reset active train")
                                        
                                        
                                    }.onDisappear() {
                                        
                                    }
                                
                                Text(RouteIdToName(routeId: trains[i].vehicle.trip.routeId))
                                if (!tripDetails.isEmpty && (tripDetails[0].stopTimeUpdate[0].departure?.delay ?? 0) > 300) {
                                    Rectangle().frame(width: 10, height: 10, alignment: .center).foregroundColor(Color.red).cornerRadius(1000)
                                } else {
                                    Rectangle().frame(width: 10, height: 10, alignment: .center).foregroundColor(Color.green).cornerRadius(1000)
                                }
                                Spacer()
                                HStack(spacing: 0) {
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 24, weight: .light))
                                    NavigationLink(destination: TrainDetailedView(tripId: trains[i].vehicle.trip.tripId),isActive: $trainShowed[i]) {
                                        EmptyView().onTapGesture {
                                            print("triggered - user wanted to go to " + trains[i].vehicle.trip.tripId)
                                            trainShowed[i] = trains[i].vehicle.trip.tripId == activeTrainId
                                            
                                            
                                        }.background(Color.red)
                                    }.onTapGesture {
                                        print("wouhuu")
                                    }.background(Color.red)
                                        .frame(width: 0)
                                        .opacity(0)
                                }.onTapGesture {
                                    print("SLURRRP")
                                }
                            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading).accentColor(CustomColors.MarcBlue)
                            
                        }} else {
                            Text("Loading").onAppear() {
                                trainShowed = Array(repeating: false, count: trains.count)
                                
                            }
                         
                        }
                }
            } else {
                
                Text("No Trains Found")
                Spacer()
              
            }
            
        }
            //2.
            .onAppear() {
                var count = UserDefaults.standard.integer(forKey: "processCompletedCountKey")
                if count == 16  {
                    SKStoreReviewController.requestReview()
                     }
                    apiCall().getTrains { (trains) in
                        self.trains = trains
                    }
                apiCall().getTripUpdates{(updates) in
                    self.tripDetails = updates
                }
                Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { timer in
                
                    if (activeTrainId == "") {
                        print("updating train list details")
                        apiCall().getTrains { (trains) in
                            self.trains = trains
                        }
                        apiCall().getTripUpdates { (updates) in
                            self.tripDetails = updates
                        }
                    }
     
            }
            }
        
        
    }
}

