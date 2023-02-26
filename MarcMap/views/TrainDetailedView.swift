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
                                region.center.longitude = trains[0].vehicle.position.longitude
                                region.center.latitude = trains[0].vehicle.position.latitude
                            }
                            self.details = trains.filter{
                                $0.vehicle.trip.tripId == tripId
                            }
                            Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { timer1 in
                                apiCall().getTrains { (trains) in
                                    if (!trains.isEmpty){
                                        region.center.longitude = trains[0].vehicle.position.longitude
                                        region.center.latitude = trains[0].vehicle.position.latitude
                                    }
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
                            tripDetails[0].stopTimeUpdate = tripDetails[0].stopTimeUpdate.reversed()
                        }
                        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { timer2 in
                            apiCall().getTripUpdates { (updates) in
                                self.tripDetails = updates.filter{
                                    $0.trip.tripId == tripId
                                }
                                tripDetails[0].stopTimeUpdate = tripDetails[0].stopTimeUpdate.reversed()
                            }}
                        
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
                        var tD = tripDetails[0].stopTimeUpdate
                        VStack(alignment: .trailing) {
                            List(tD) { stop in
                                
                                HStack {
                                    if (Double(stop.departure?.time ?? "0")! > NSDate().timeIntervalSince1970 || Double(stop.arrival?.time ?? "0")! > NSDate().timeIntervalSince1970 ) {
                                        Text(GetStationFromStopId(stopID: Int(stop.stopId)!).stop_name)
                                        Spacer()
                                        Text(stop.arrival?.time != nil ? FormatTime(timestamp: stop.arrival!.time) : stop.departure?.time != nil ? FormatTime(timestamp: stop.departure!.time): "Unknown").bold()
                                    } else {
                                        Text(GetStationFromStopId(stopID: Int(stop.stopId)!).stop_name).foregroundColor(Color.gray)
                                        Spacer()
                                        Text(stop.arrival?.time != nil ? FormatTime(timestamp: stop.arrival!.time) : stop.departure?.time != nil ? FormatTime(timestamp: stop.departure!.time): "Unknown").bold().foregroundColor(Color.gray)
                                    }
                                  
                                }
                            
                        }
                       
                        }.frame(alignment: .leading).padding(.top, 0).background(Color.white)
                
                    }
                   
                        
                    
                    Spacer()
                
                
            }
            
        }
    }
}
