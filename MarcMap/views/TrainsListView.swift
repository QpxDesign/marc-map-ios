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
    @State var takeToDonate: Bool = false
    @State var showDonateAlert: Bool = false
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
                                    if #available(iOS 17.0, *) {
                                        NavigationLink(destination: NewTrainDetailedView(tripId: trains[i].vehicle.trip.tripId),isActive: $trainShowed[i]) {
                                            EmptyView().onTapGesture {
                                                print("triggered - user wanted to go to " + trains[i].vehicle.trip.tripId)
                                                trainShowed[i] = trains[i].vehicle.trip.tripId == activeTrainId
                                                
                                                
                                            }.background(Color.red)
                                        }.onTapGesture {
                                            print("wouhuu")
                                        }.accentColor(Color.black)
                                            .frame(width: 0)
                                            .opacity(0)
                                    } else {
                                        NavigationLink(destination: TrainDetailedView(tripId: trains[i].vehicle.trip.tripId),isActive: $trainShowed[i]) {
                                            EmptyView().onTapGesture {
                                                print("triggered - user wanted to go to " + trains[i].vehicle.trip.tripId)
                                                trainShowed[i] = trains[i].vehicle.trip.tripId == activeTrainId
                                                
                                                
                                            }.background(Color.red)
                                        }.accentColor(Color.black).onTapGesture {
                                            print("wouhuu")
                                        }.background(Color.red)
                                            .frame(width: 0)
                                            .opacity(0)
                                    }
                                }.onTapGesture {
                                    print("SLURRRP")
                                }
                            }
                            
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
            
        } .alert("Please Donate", isPresented: $showDonateAlert) {
                Button {
                    showDonateAlert = false
                } label: {
                    Text("No Thanks.")
                }
            Button {
                takeToDonate = true
                } label: {
                    Text("Donate")
                }
           
        }  message: {
            Text("To keep MarcMap free and adless for all, please consider donating to help cover developmental costs. Any bit helps.")
        }
            //2.
            .onAppear() {
                Task {
                    for await verificationResult in Transaction.updates {
                        UserDefaults.standard.set(verificationResult.jwsRepresentation, forKey: "purchaseJWT")
                    }
                }
                var count = UserDefaults.standard.integer(forKey: "processCompletedCountKey")
                UserDefaults.standard.set(count+1, forKey: "processCompletedCountKey")
                if count == 16  {
                    SKStoreReviewController.requestReview()
                     }
                if count % 1 == 10 && (UserDefaults.standard.string(forKey: "purchaseJWT") == "" || UserDefaults.standard.string(forKey: "purchaseJWT") == nil)  {
                    showDonateAlert = true
                }

                    apiCall().getTrains { (trains) in
                        self.trains = trains ?? []
                    }
                apiCall().getTripUpdates{(updates) in
                    self.tripDetails = updates ?? []
                }
                Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { timer in
                
                    if (activeTrainId == "") {
                        print("updating train list details")
                        apiCall().getTrains { (trains) in
                            self.trains = trains ?? []
                        }
                        apiCall().getTripUpdates { (updates) in
                            self.tripDetails = updates ?? []
                        }
                    }
     
            }
            } .background(
                NavigationLink(
                    destination: SettingsView(),
                    isActive: $takeToDonate
                ) {
                    EmptyView()
                }
            )
        
        
    }
}
