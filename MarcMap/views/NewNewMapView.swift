//
//  NewNewMapView.swift
//  MarcMap
//
//  Created by Quinn Patwardhan on 11/29/23.
//


import Foundation
import MapKit
import SwiftUI

@available(iOS 17.0, *)
struct NewNewMapView: View {
    
    @State private var TrainPopups: [TrainPopup] = []
    @State private var StationPopups: [StationPopup] = []
    @State private var LastTimePopUpOpen: Double = 0
    @State private var didLoadTrains: Bool = false
    @State var trains = [Train]()
    @State var suppliedLoc : CLLocationCoordinate2D?
    @State var suppliedSpan: MKCoordinateSpan?
    @State var loc :  CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 38.9072, longitude: -77.0369)
    @State var span : MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25)
    @State private var position: MapCameraPosition = .automatic

    let manager = LocationManager()
    var body: some View {
        ZStack {
            Map(position: $position) {
                MapPolyline(coordinates: getRouteFromFile(filename: "Brunswick") ?? [CLLocationCoordinate2D(latitude: 0, longitude: 0)] ).stroke(CustomColors.BrunswickColor, lineWidth: 10.0)
                MapPolyline(coordinates: getRouteFromFile(filename: "FredrickBranch")  ?? [CLLocationCoordinate2D(latitude: 0, longitude: 0)]).stroke(CustomColors.BrunswickColor, lineWidth: 10.0)
                
                MapPolyline(coordinates: getRouteFromFile(filename: "Penn")  ?? [CLLocationCoordinate2D(latitude: 0, longitude: 0)]).stroke(CustomColors.PennColor, lineWidth: 10.0)
                MapPolyline(coordinates: getRouteFromFile(filename: "Camden")  ?? [CLLocationCoordinate2D(latitude: 0, longitude: 0)]).stroke(CustomColors.CamdenColor, lineWidth: 10.0)
                
                ForEach(StationPopups.indices, id: \.self) { index1 in
                    Annotation(StationPopups[index1].name,
                               coordinate: StationPopups[index1].coordinate
                    ) {
                        Image("StationIcon")
                            .font(.title).zIndex(1)
                    }
                }
                ForEach(TrainPopups.indices, id: \.self) { index in
                    Annotation("",
                               coordinate: TrainPopups[index].coordinate
                    ) {
                        VStack{
                            var line1 = "Next Stop: \(TrainPopups[index].nextStop ?? "") @ \(FormatTime(timestamp: TrainPopups[index].nextStopETA ?? ""))"
                            var line2 = "Final Stop: \(TrainPopups[index].finalStop ?? "") @ \(FormatTime(timestamp: TrainPopups[index].finalStopETA ?? ""))"
                            if TrainPopups[index].show {
                                ZStack {
                                    VStack {
                                        Text(FormatTripId(tripId: TrainPopups[index].tripID ?? "")).font(.system(size: 25)).fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).padding(.horizontal,15).padding(.bottom,0).foregroundColor(Color.black)
                                        Text(TrainPopups[index].line ?? "").padding(0).fontWeight(.light).foregroundColor(Color.black)
                                        Text(line1).padding(0).multilineTextAlignment(.center).foregroundColor(Color.black)
                                        Text(line2).padding(0).multilineTextAlignment(.center).padding(.top,5).foregroundColor(Color.black)
                                    }.padding(.horizontal,15).padding(.vertical, 10).background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.white)
                                    ).frame(width: 325,height:200).position(x: 0, y: 0).zIndex(1000)
                                    
                                    Image("TrainIcon")
                                        .zIndex(5)
                                        .font(.title)
                                        .onTapGesture {
                                            print("did tap open")
                                            TrainPopups[index].show = false
                                        }
                                }
                            } else {
                                Image("TrainIcon")
                                    .font(.title)
                                    .zIndex(5)
                                    .foregroundColor(.red)
                                    .onTapGesture {
                                        
                                        var idx2 = 0
                                        for tp in TrainPopups {
                                            TrainPopups[idx2].show = false
                                            idx2 += 1
                                        }
                                        TrainPopups[index].show = true
                                        print(TrainPopups[index].show)
                                    }
                            }
                        }
                        
                    }
                }
            }.zIndex(0).onTapGesture {
                print("did tap map")
                if (LastTimePopUpOpen == 0 || NSDate().timeIntervalSince1970-LastTimePopUpOpen > 0.25) {
                    LastTimePopUpOpen = NSDate().timeIntervalSince1970
                    
                    
                    if TrainPopups.filter{$0.show == true}.count != 0 {
                        var idx2 = 0
                        for tp in TrainPopups {
                           // TrainPopups[idx2].show = false
                            idx2 += 1
                        }
                    }
                    
                }
            }.onAppear() {
                if (suppliedLoc != nil) {
                    print("killme1")
                    position = .region(MKCoordinateRegion(center: suppliedLoc ?? loc, span:suppliedSpan ?? span ))
                } else {
                    position = .region(MKCoordinateRegion(center: loc, span: span))
                }
                let userLocation = manager.location
                //loc = CLLocationCoordinate2D(latitude: userLocation?.coordinate.latitude ?? 38.9072, longitude: userLocation?.coordinate.longitude ?? 77.0369)
                //span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                if didLoadTrains == false {
                    for station in getStations() {
                        StationPopups.append(StationPopup(coordinate: CLLocationCoordinate2D(latitude: station.stop_lat,longitude: station.stop_lon), name: station.stop_name, station: station))
                    }
                    apiCall().getTrains { (trains) in
                        apiCall().getTripUpdates { (tripUpdates) in
                            for train in (trains ?? []) {
                                if (tripUpdates ?? []).filter{$0.trip.tripId == train.vehicle.trip.tripId}.count != 0 {
                                    var relevantTripUpdate = (tripUpdates ?? []).filter{$0.trip.tripId == train.vehicle.trip.tripId}[0]
                                    var delay = ""
                                    var nextStop = ""
                                    var nextStopETA = ""
                                    relevantTripUpdate.stopTimeUpdate.forEach { stop in
                                        if delay == "" {
                                            if (stop.departure != nil && stop.departure?.time ?? "0" > relevantTripUpdate.timestamp) || (stop.arrival != nil && stop.arrival?.time ?? "0" > relevantTripUpdate.timestamp) {
                                                var d1 = stop.arrival?.delay ?? 0
                                                delay = String(round(Double(d1/60)))
                                                nextStop = GetStationFromStopId(stopID: Int(stop.stopId) ?? 0).stop_name
                                                nextStopETA = stop.arrival?.time ?? "0"
                                            }
                                        }
                                    }
                                    // filter{$0.departure.time > $0.timestamp}
                                    
                                    TrainPopups.append(TrainPopup(coordinate: CLLocationCoordinate2D(latitude: train.vehicle.position.latitude, longitude: train.vehicle.position.longitude), tripID: train.vehicle.trip.tripId,line: RouteIdToName(routeId: train.vehicle.trip.routeId), delay: delay, nextStop: nextStop, nextStopETA: nextStopETA, finalStop: GetStationFromStopId(stopID: Int(relevantTripUpdate.stopTimeUpdate[relevantTripUpdate.stopTimeUpdate.count-1].stopId) ?? 0).stop_name, finalStopETA: relevantTripUpdate.stopTimeUpdate[relevantTripUpdate.stopTimeUpdate.count-1].arrival?.time))
                                }
                            }
                        }
                    }
                    didLoadTrains = true
                    Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { timer in
                        apiCall().getTrains { (trains) in
                            apiCall().getTripUpdates { (tripUpdates) in
                                TrainPopups = []
                                for train in (trains ?? []) {
                                    if (tripUpdates ?? []).filter{$0.trip.tripId == train.vehicle.trip.tripId}.count != 0 {
                                        var relevantTripUpdate = (tripUpdates ?? []).filter{$0.trip.tripId == train.vehicle.trip.tripId}[0]
                                        var delay = ""
                                        var nextStop = ""
                                        var nextStopETA = ""
                                        relevantTripUpdate.stopTimeUpdate.forEach { stop in
                                            if delay == "" {
                                                if (stop.departure != nil && stop.departure?.time ?? "0" > relevantTripUpdate.timestamp) || (stop.arrival != nil && stop.arrival?.time ?? "0" > relevantTripUpdate.timestamp) {
                                                    var d1 = stop.arrival?.delay ?? 0
                                                    delay = String(round(Double(d1/60)))
                                                    nextStop = GetStationFromStopId(stopID: Int(stop.stopId) ?? 0).stop_name
                                                    nextStopETA = stop.arrival?.time ?? "0"
                                                }
                                            }
                                        }
                                        // filter{$0.departure.time > $0.timestamp}
                                        
                                        TrainPopups.append(TrainPopup(coordinate: CLLocationCoordinate2D(latitude: train.vehicle.position.latitude, longitude: train.vehicle.position.longitude), tripID: train.vehicle.trip.tripId,line: RouteIdToName(routeId: train.vehicle.trip.routeId), delay: delay, nextStop: nextStop, nextStopETA: nextStopETA, finalStop: GetStationFromStopId(stopID: Int(relevantTripUpdate.stopTimeUpdate[relevantTripUpdate.stopTimeUpdate.count-1].stopId) ?? 0).stop_name, finalStopETA: relevantTripUpdate.stopTimeUpdate[relevantTripUpdate.stopTimeUpdate.count-1].arrival?.time))
                                    }
                                }
                            }
                        }
                }
                }
            }
            Image(systemName: "location.fill").foregroundColor(.white).font(.system(size: 28.0)).padding(12).background(Color.black).position(x:50,y:35).onTapGesture {
                print("changed loc 87")
                let userLocation = manager.location
                loc = CLLocationCoordinate2D(latitude: userLocation?.coordinate.latitude ?? 38.9072, longitude: userLocation?.coordinate.longitude ?? 77.0369)
                span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                position = .region(MKCoordinateRegion(center: loc, span: span))
            }
        }
        }
    }
    

