//
//  NewMapView.swift
//  MarcMap
//
//  Created by Quinn Patwardhan on 11/11/23.
//

import Foundation
import MapKit
import SwiftUI

struct NewMapView: View {

    @State private var TrainPopups: [TrainPopup] = []
    @State private var didLoadTrains: Bool = false
    @State var trains = [Train]()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 38.9072,
            longitude: -77.0369
        ),
        span: MKCoordinateSpan(
            latitudeDelta: 1,
            longitudeDelta: 1
        )
    )
 
    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, annotationItems: TrainPopups) { location in
                MapAnnotation(
                    coordinate: location.coordinate,
                    anchorPoint: CGPoint(x: 0.5, y: 0.7)
                ) {
                    
                    VStack{
                        var line1 = "Next Stop: \(location.nextStop ?? "") @ \(FormatTime(timestamp: location.nextStopETA ?? ""))"
                        var line2 = "Final Stop: \(location.finalStop ?? "") @ \(FormatTime(timestamp: location.finalStopETA ?? ""))"
                        if location.show {
                            VStack {
                                Text(FormatTripId(tripId: location.tripID ?? "")).font(.system(size: 25)).fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).padding(.horizontal,15).padding(.bottom,0).foregroundColor(Color.black)
                                Text(location.line ?? "").padding(0).fontWeight(.light).foregroundColor(Color.black)
                                Text(line1).padding(0).multilineTextAlignment(.center).foregroundColor(Color.black)
                                Text(line2).padding(0).multilineTextAlignment(.center).padding(.top,5).foregroundColor(Color.black)
                            }.padding(.horizontal,15).padding(.vertical, 10).background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white)
                            ).frame(width: 325,height:200)
                            Image("TrainIcon")
                                .font(.title)
                                .padding(.bottom,50)
                                .onTapGesture {
                                    print("did tap open")
                                    let index: Int = TrainPopups.firstIndex(where: {$0.id == location.id})!
                                    TrainPopups[index].show = false
                                }
                        } else {
                            VStack {
                            }.frame(width: 325,height:200)
                            Image("TrainIcon")
                                .font(.title)
                                .foregroundColor(.red)
                                .padding(.bottom,50)
                                .onTapGesture {
                                    
                                    var idx2 = 0
                                    for tp in TrainPopups {
                                        TrainPopups[idx2].show = false
                                        idx2 += 1
                                    }
                                    let index: Int = TrainPopups.firstIndex(where: {$0.id == location.id})!
                                    print("did tap try to open - \(index)")
                                    TrainPopups[index].show = true
                                    print(TrainPopups[index].show)
                                }
                        }
                    }
                    
                }
            }
            .onTapGesture {
                if TrainPopups.filter{$0.show == true}.count != 0 {
                    var idx2 = 0
                    for tp in TrainPopups {
                        TrainPopups[idx2].show = false
                        idx2 += 1
                    }
                }
            }
        }.onAppear() {


            if didLoadTrains == false {
                apiCall().getTrains { (trains) in
                    apiCall().getTripUpdates { (tripUpdates) in
                        for train in trains {
                            if tripUpdates.filter{$0.trip.tripId == train.vehicle.trip.tripId}.count != 0 {
                                var relevantTripUpdate = tripUpdates.filter{$0.trip.tripId == train.vehicle.trip.tripId}[0]
                                var delay = ""
                                var nextStop = ""
                                var nextStopETA = ""
                                relevantTripUpdate.stopTimeUpdate.forEach { stop in
                                    if delay == "" {
                                        if (stop.departure != nil && stop.departure!.time > relevantTripUpdate.timestamp) || (stop.arrival != nil && stop.arrival!.time > relevantTripUpdate.timestamp) {
                                            var d1 = stop.arrival?.delay ?? 0
                                            delay = String(round(Double(d1/60)))
                                            nextStop = GetStationFromStopId(stopID: Int(stop.stopId)!).stop_name
                                            nextStopETA = stop.arrival!.time
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
            }
        }
    }
}
