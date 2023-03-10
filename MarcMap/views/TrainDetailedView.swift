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
    let brunswick : [CLLocationCoordinate2D] = getRouteFromFile(filename: "Brunswick")!
    let penn : [CLLocationCoordinate2D] = getRouteFromFile(filename: "Penn")!
    let fred : [CLLocationCoordinate2D] = getRouteFromFile(filename: "FredrickBranch")!
    let camd : [CLLocationCoordinate2D] = getRouteFromFile(filename: "Camden")!

        var body: some View {
            GeometryReader { geometry in
        
                VStack {
                    HStack {
                        Text(details.isEmpty ? "Loading" : FormatTripId(tripId: details[0].vehicle.trip.tripId)).bold().multilineTextAlignment(.leading).padding(.leading,20).padding(.bottom, 15).foregroundColor(Color.white).font(.system(size: 34))
                    } .frame(maxWidth: .infinity, alignment: .leading).background(CustomColors.MarcOrange).onAppear() {
                        apiCall().getTrains { (trains) in
                            if (!trains.isEmpty){
                            //    region.center.longitude = trains[0].vehicle.position.longitude
                              //  region.center.latitude = trains[0].vehicle.position.latitude
                            }
                            
                            self.details = trains.filter{
                                $0.vehicle.trip.tripId == tripId
                            }
                           Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { timer1 in
                                apiCall().getTrains { (trains) in
                                    if (!trains.isEmpty){
                                   //     region.center.longitude = trains[0].vehicle.position.longitude
                                   //     region.center.latitude = trains[0].vehicle.position.latitude
                                    }
                                    print("updated trains in timer!")
                                    self.details = trains.filter{
                                        $0.vehicle.trip.tripId == tripId
                                    }
                                }
                            }
                        }
                        apiCall().getTripUpdates{(updates) in
                            self.tripDetails = updates.filter{
                                $0.trip.tripId == tripId
                            }
                         
                            tripDetails[0].stopTimeUpdate = tripDetails[0].stopTimeUpdate
                        }
                        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { timer2 in
                            apiCall().getTripUpdates { (updates) in
                                print("updated trains in updates!")
                                self.tripDetails = updates.filter{
                                    $0.trip.tripId == tripId
                                }
                        tripDetails[0].stopTimeUpdate = tripDetails[0].stopTimeUpdate                            }}
                        
                    }
                    if (!details.isEmpty) {
                        Text("Last Updated: " + FormatTime(timestamp: details[0].vehicle.timestamp))
                        NavigationLink(destination: FullScreenMap(tripId:tripId, trains:details, region: region)) {
                            MapView(region: region, BrunswickLineCoordinates: brunswick, PennLineCoordinates: penn, CamdenLineCoordinates: camd, FredrickBranchLineCoordinates: fred,trains:details, tripId: tripId).frame(width:geometry.size.width * 0.90,height:geometry.size.height*0.35).cornerRadius(15).padding(.bottom, 0)
                        }
                    } else {
                        Text("Loading")
                    }
                    if (!tripDetails.isEmpty && !tripDetails[0].stopTimeUpdate.isEmpty) {
                        var tD = tripDetails[0].stopTimeUpdate.filter{Double($0.departure?.time ?? "0")! > NSDate().timeIntervalSince1970 || Double($0.arrival?.time ?? "0") ?? 0 > NSDate().timeIntervalSince1970 }
                        var tDa = tripDetails[0].stopTimeUpdate.filter{Double($0.departure?.time ?? "0")! < NSDate().timeIntervalSince1970 || Double($0.arrival?.time ?? "0") ?? 0 < NSDate().timeIntervalSince1970 }
                        var t = removeDuplicates(arr: tD+tDa)
                        VStack(alignment: .trailing) {
                            List(t) { stop in
                            //    if (stop.departure.self != nil) {
                                    HStack {
                                        if (Double(stop.departure?.time ?? "0")! > NSDate().timeIntervalSince1970+30 || Double(stop.arrival?.time ?? "0")! > NSDate().timeIntervalSince1970+30 ) {
                                            Text(GetStationFromStopId(stopID: Int(stop.stopId)!).stop_name)
                                            Spacer()
                                            Text(stop.arrival?.time != nil ? FormatTime(timestamp: stop.arrival!.time) : stop.departure?.time != nil ? FormatTime(timestamp: stop.departure!.time): "Unknown").bold()
                                        } else {
                                            Text(GetStationFromStopId(stopID: Int(stop.stopId)!).stop_name).foregroundColor(Color.gray)
                                            Spacer()
                                            Text(stop.arrival?.time != nil ? FormatTime(timestamp: stop.arrival!.time) : stop.departure?.time != nil ? FormatTime(timestamp: stop.departure!.time): "Unknown").bold().foregroundColor(Color.gray)
                                        }
                                        }
                                  //  }
                                }
                           HStack {
                               if #available(iOS 16.0, *) {
                                   Text("Last Stop: " + GetStationFromStopId(stopID: Int(tripDetails[0].stopTimeUpdate.last?.stopId ?? "0")!).stop_name).foregroundColor(Color.white).padding(10).background(CustomColors.MarcBlue).bold().frame(maxWidth:.infinity)
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
 
func removeDuplicates(arr : Array<stopTimeUpdate>) -> Array<stopTimeUpdate> {
    var a : [stopTimeUpdate] = []
    for i in arr {
        if (a.filter{$0.id.uuidString == i.id.uuidString}.count == 0) {
            a.append(i)
        }
    }
    return a;
}
