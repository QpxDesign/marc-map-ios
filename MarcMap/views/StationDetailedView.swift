//
//  StationDetailedView.swift
//  MarcMap
//
//  Created by Quinn Patwardhan on 2/26/23.
//

import SwiftUI
import CoreLocation
import CoreLocationUI
import MapKit

struct StationDetailedView: View {
    var stationObj: station
    @State var trains = [Train]()
    @State var details = [tripUpdate]()
    @State var activeTrain = false
    @State var showAllTrains = false
    let brunswick : [CLLocationCoordinate2D] = getRouteFromFile(filename: "Brunswick")!
    let penn : [CLLocationCoordinate2D] = getRouteFromFile(filename: "Penn")!
    let fred : [CLLocationCoordinate2D] = getRouteFromFile(filename: "FredrickBranch")!
    let camd : [CLLocationCoordinate2D] = getRouteFromFile(filename: "Camden")!
    var timer1 = Timer()
    var timer2 = Timer()
    
    @State var trainShowed : [Bool] = []
    var body: some View {
        
        GeometryReader { geometry in
            
            VStack {
                HStack {
                    Text(stationObj.stop_name).bold().multilineTextAlignment(.leading).padding(.leading,20).padding(.bottom, 15).foregroundColor(Color.white).font(.system(size: 34))
                } .frame(maxWidth: .infinity, alignment: .leading).background(CustomColors.MarcOrange).onAppear() {
                    
                        apiCall().getTrains { (trains) in
                            self.trains = trains
                           
                                Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { timer1 in
                                    if (!activeTrain) {
                                    apiCall().getTrains { (trains) in
                                        self.trains = trains
                                    }
                                }
                            }
                        }
                        apiCall().getTripUpdates{(updates) in
                            self.details = updates
                        }
                  
                        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { timer2 in
                            if (!activeTrain) {
                            apiCall().getTripUpdates { (updates) in
                                self.details = updates
                            }}
                    }
                    }
              
                  //  Text("Last Updated: " + FormatTime(timestamp: trains[0].vehicle.timestamp))
                    NavigationLink(destination: FullScreenMap(tripId:"Null", trains:trains, region:  MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude:self.stationObj.stop_lat, longitude:  self.stationObj.stop_lon),
                       latitudinalMeters: 75,
                       longitudinalMeters: 75))) {
                        MapView(region:  MKCoordinateRegion(
                            center: CLLocationCoordinate2D(latitude:self.stationObj.stop_lat, longitude:  self.stationObj.stop_lon),
                           latitudinalMeters: 75,
                           longitudinalMeters: 75), BrunswickLineCoordinates: brunswick, PennLineCoordinates: penn, CamdenLineCoordinates: camd, FredrickBranchLineCoordinates: fred,trains:trains, tripId: "Null").frame(width:geometry.size.width * 0.90,height:geometry.size.height*0.35).cornerRadius(15).padding(.bottom, 0)
                       }
                if (!details.isEmpty) {
                    if (!trainShowed.isEmpty) {
                        HStack {
                            HStack {
                                Text("Tracked Trains").fontWeight(Font.Weight.medium)
                            }.padding([.leading,.trailing],15).padding([.vertical,.horizontal],5).background(showAllTrains ? Color.gray : Color.orange).cornerRadius(25).onTapGesture{
                                showAllTrains = false
                            }
                            HStack {
                                Text("All Trains").fontWeight(Font.Weight.medium)
                            }.padding([.leading,.trailing],15).padding([.vertical,.horizontal],5).background(showAllTrains ? Color.orange : Color.gray).cornerRadius(25).onTapGesture{
                                showAllTrains = true
                            }
                        }
                        if (!showAllTrains) {
                            List( GetTrainsGoingToStation(stopId: stationObj.stop_id,trains:trains,details:details).indices) { i in
                                VStack(alignment: .leading) {
                         
                                    HStack {
                                        Text(FormatTripId(tripId: GetTrainsGoingToStation(stopId: stationObj.stop_id,trains:trains,details:details)[i].tripId))
                                            .font(.title)
                                            .fontWeight(.bold)
                                        
                                        Text(RouteIdToName(routeId: GetTrainsGoingToStation(stopId: stationObj.stop_id,trains:trains,details:details)[i].line))
                                        if (GetTrainsGoingToStation(stopId: stationObj.stop_id,trains:trains,details:details)[i].delay ?? 0 > 300) {
                                            Rectangle().frame(width: 10, height: 10, alignment: .center).foregroundColor(Color.red).cornerRadius(1000)
                                        } else {
                                            Rectangle().frame(width: 10, height: 10, alignment: .center).foregroundColor(Color.green).cornerRadius(1000)
                                        }
                                        
                                        Spacer()
                                        HStack(spacing: 0) {
                                            Image(systemName: "arrow.right")
                                                .font(.system(size: 24, weight: .light))
                                            
                                            NavigationLink(destination: TrainDetailedView(tripId: GetTrainsGoingToStation(stopId: stationObj.stop_id,trains:trains,details:details)[i].tripId),isActive: $trainShowed[i]) {
                                                EmptyView()
                                            }
                                            .frame(width: 0)
                                            .opacity(0)
                                        }.onTapGesture {
                                            activeTrain = true
                                        }
                                        
                                    }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading).accentColor(CustomColors.MarcBlue)
                                }
                        }
                    
                        } else {
                            List(stationObj.static_stops.indices) { i in
                                VStack(alignment: .leading) {
                                    
                                    HStack {
                                        Text(stationObj.static_stops[i].trainID ?? "Error")
                                            .font(.system(size: 20))
                                            .fontWeight(.bold)
                                        
                                        Text(stationObj.static_stops[i].time ?? "Error")
                                        Spacer()
                                        Text(stationObj.static_stops[i].direction ?? "Error")
                                        
                                    }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading).accentColor(CustomColors.MarcBlue)
                               Spacer()
                                }
                            }
                        }
                    } else {
                        Text("").onAppear(){
                            trainShowed = Array(repeating: false, count: GetTrainsGoingToStation(stopId: stationObj.stop_id,trains:trains,details:details).count)
                        }
                    }
                } else {
                    Text("No Trains Found")
                }
                Spacer()
            }
        }
    }
}
