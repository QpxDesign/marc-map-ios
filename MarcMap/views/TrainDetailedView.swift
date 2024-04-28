//
//  TrainDetailedView.swift
//  hello-world
//
//  Created by Quinn Patwardhan on 2/22/23.
//
import Foundation
import SwiftUI
import MapKit

struct TrainDetailedView: View {
    var tripId : String;
    @State var details = [Train]()
    @State var tripDetails = [tripUpdate]()
    @State var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude:38.9072, longitude:  -77.0369),
        latitudinalMeters: 15000,
        longitudinalMeters: 15000)
    var timer1 = Timer()
    var timer2 = Timer()
    let brunswick : [CLLocationCoordinate2D] = getRouteFromFile(filename: "Brunswick") ?? [CLLocationCoordinate2D(latitude: 0, longitude: 0)]
    let penn : [CLLocationCoordinate2D] = getRouteFromFile(filename: "Penn") ?? [CLLocationCoordinate2D(latitude: 0, longitude: 0)]
    let fred : [CLLocationCoordinate2D] = getRouteFromFile(filename: "FredrickBranch") ?? [CLLocationCoordinate2D(latitude: 0, longitude: 0)]
    let camd : [CLLocationCoordinate2D] = getRouteFromFile(filename: "Camden") ?? [CLLocationCoordinate2D(latitude: 0, longitude: 0)]

        var body: some View {
            GeometryReader { geometry in
                if (!details.isEmpty && details.filter{$0.vehicle.trip.tripId == tripId}.isEmpty) {
                    TrainsListView()
                }
                VStack {
                    HStack {
                        Text(details.isEmpty ? "Loading" : FormatTripId(tripId: details[0].vehicle.trip.tripId)).bold().multilineTextAlignment(.leading).padding(.leading,20).padding(.bottom, 15).foregroundColor(Color.white).font(.system(size: 34))
                    } .frame(maxWidth: .infinity, alignment: .leading).background(CustomColors.MarcOrange).onAppear() {

                        apiCall().getTrains { (trains) in
                            if (!(trains ?? []).isEmpty){
                            //    region.center.longitude = trains[0].vehicle.position.longitude
                              //  region.center.latitude = trains[0].vehicle.position.latitude
                            }
                            
                            self.details = (trains ?? []).filter{
                                $0.vehicle.trip.tripId == tripId
                            }
                           Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { timer1 in
                                apiCall().getTrains { (trains) in
                                    if (!(trains ?? []).isEmpty){
                                   //     region.center.longitude = trains[0].vehicle.position.longitude
                                   //     region.center.latitude = trains[0].vehicle.position.latitude
                                    }
                                    print("updated trains in timer!")
                                    self.details = (trains ?? []).filter{
                                        $0.vehicle.trip.tripId == tripId
                                    }
                                }
                            }
                        }
                        apiCall().getTripUpdates{(updates) in
                            self.tripDetails = (updates ?? []).filter{
                                $0.trip.tripId == tripId
                            }
                         
                            tripDetails[0].stopTimeUpdate = tripDetails[0].stopTimeUpdate
                        }
                        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { timer2 in
                            apiCall().getTripUpdates { (updates) in
                                print("updated trains in updates!")
                                self.tripDetails = (updates ?? []).filter{
                                    $0.trip.tripId == tripId
                                }
                                }}
                        
                    }
                    if (!details.isEmpty) {
                        Text("Last Updated: " + FormatTime(timestamp: details[0].vehicle.timestamp))
                        NavigationLink(destination: FullScreenMap(tripId:tripId, trains:details, region: region)) {
                            MapView(region: region, BrunswickLineCoordinates: brunswick, PennLineCoordinates: penn, CamdenLineCoordinates: camd, FredrickBranchLineCoordinates: fred,trains:details, tripId: tripId).frame(width:geometry.size.width * 0.90,height:geometry.size.height*0.35).cornerRadius(15).padding(.bottom, 0)
                        }.accentColor(Color.black)
                    } else {
                        Text("Loading")
                    }
                    if (!tripDetails.isEmpty && !tripDetails[0].stopTimeUpdate.isEmpty) {
                        var tD = tripDetails[0].stopTimeUpdate.filter{Double($0.departure?.time ?? "0") ?? 0 > NSDate().timeIntervalSince1970 || Double($0.arrival?.time ?? "0") ?? 0 > NSDate().timeIntervalSince1970 }
                        var tDa = tripDetails[0].stopTimeUpdate.filter{Double($0.departure?.time ?? "0") ?? 0 < NSDate().timeIntervalSince1970 || Double($0.arrival?.time ?? "0") ?? 0 < NSDate().timeIntervalSince1970 }
                        var t = removeDuplicates(arr: tD+tDa)
                        VStack(alignment: .trailing) {
                            List(t) { stop in
                            //    if (stop.departure.self != nil) {
                                    HStack {
                                        if (Double(stop.departure?.time ?? "0") ?? 0 > NSDate().timeIntervalSince1970+30 || Double(stop.arrival?.time ?? "0") ?? 0 > NSDate().timeIntervalSince1970+30 ) {
                                            Text(GetStationFromStopId(stopID: Int(stop.stopId) ?? 0).stop_name)
                                            Spacer()
                                            Text(stop.arrival?.time != nil ? FormatTime(timestamp: stop.arrival?.time ?? "") : stop.departure?.time != nil ? FormatTime(timestamp: stop.departure?.time ?? ""): "Unknown").bold()
                                        } else {
                                            Text(GetStationFromStopId(stopID: Int(stop.stopId) ?? 0).stop_name).foregroundColor(Color.gray)
                                            Spacer()
                                            Text(stop.arrival?.time != nil ? FormatTime(timestamp: stop.arrival?.time ?? "0") : stop.departure?.time != nil ? FormatTime(timestamp: stop.departure?.time ?? "0"): "Unknown").bold().foregroundColor(Color.gray)
                                        }
                                        }
                                  //  }
                                }
                           HStack {
                               if #available(iOS 16.0, *) {
                                   Text("Last Stop: " + GetStationFromStopId(stopID: Int(tripDetails[0].stopTimeUpdate.last?.stopId ?? "0") ?? 0).stop_name).foregroundColor(Color.white).padding(10).background(CustomColors.MarcBlue).bold().frame(maxWidth:.infinity)
                               } else {
                                   // Fallback on earlier versions
                               }
                           }.frame(maxWidth:.infinity, alignment:.center).font(.system(size: 18)).background(CustomColors.MarcBlue).padding(.horizontal, 10)
                        }.frame(alignment: .leading).padding(.top, 0).onDisappear() {
                            print("unloaded :(")
                        }
                
                    } else {
                        Text("Loading")
                    }
                    
                    Spacer()
            }
            
        }
    }
}

