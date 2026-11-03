//
//  NewNewMapView.swift
//  MarcMap
//
//  Created by Quinn Patwardhan on 11/29/23.
//

import Foundation
import MapKit
import SwiftUI

struct FullScreenMap: View {
    @ObservedObject var trainsViewModel: TrainsViewModel
    @ObservedObject var tripUpdatesViewModel: TripUpdatesViewModel
    @State private var TrainPopups: [TrainPopup] = []
    @State private var StationPopups: [StationPopup] = []
    @State var suppliedLoc: CLLocationCoordinate2D?
    @State var suppliedSpan: MKCoordinateSpan?
    @State var loc: CLLocationCoordinate2D = .init(latitude: 38.9072, longitude: -77.0369)
    @State var span: MKCoordinateSpan = .init(latitudeDelta: 0.25, longitudeDelta: 0.25)
    @State private var position: MapCameraPosition = .automatic
    
    func updateTrainPopups(train_data: [Train]) {
        // update location/data for existing popups
        for var popup in TrainPopups {
            let matching_train = train_data.filter { $0.vehicle.trip.tripId == popup.tripID }
            if matching_train.isEmpty {
                popup.expired = true
                continue
            } else {
                popup.coordinate.latitude = matching_train[0].vehicle.position.latitude
                popup.coordinate.longitude = matching_train[0].vehicle.position.longitude
            }
        }
        // remove old popups
        TrainPopups = TrainPopups.filter { $0.expired == true }
        
        // add new ones
        for train in train_data {
            let matching_popup = TrainPopups.filter { $0.tripID == train.vehicle.trip.tripId }
            if !matching_popup.isEmpty {
                continue
            }
        
            TrainPopups.append(TrainPopup(coordinate: CLLocationCoordinate2D(latitude: train.vehicle.position.latitude, longitude: train.vehicle.position.longitude), tripID: train.vehicle.trip.tripId))
        }
    }
    
    let manager = LocationManager()
    var body: some View {
        ZStack {
            Map(position: $position) {
                MapPolyline(coordinates: getRouteFromFile(filename: "Brunswick") ?? [CLLocationCoordinate2D(latitude: 0, longitude: 0)]).stroke(CustomColors.BrunswickColor, lineWidth: 10.0)
                MapPolyline(coordinates: getRouteFromFile(filename: "FredrickBranch") ?? [CLLocationCoordinate2D(latitude: 0, longitude: 0)]).stroke(CustomColors.BrunswickColor, lineWidth: 10.0)
                
                MapPolyline(coordinates: getRouteFromFile(filename: "Penn") ?? [CLLocationCoordinate2D(latitude: 0, longitude: 0)]).stroke(CustomColors.PennColor, lineWidth: 10.0)
                MapPolyline(coordinates: getRouteFromFile(filename: "Camden") ?? [CLLocationCoordinate2D(latitude: 0, longitude: 0)]).stroke(CustomColors.CamdenColor, lineWidth: 10.0)
                
                ForEach(TrainPopups) { popup in
                    Annotation("",
                               coordinate: popup.coordinate)
                    {
                        NavigationLink(destination: TrainDetailedView(tripId: popup.tripID ?? "", trainsViewModel: trainsViewModel, tripUpdatesViewModel: tripUpdatesViewModel)) {
                            Image("TrainIcon")
                        }.zIndex(5)
                    }
                }
                ForEach(StationPopups.indices, id: \.self) { index1 in
                    Annotation(StationPopups[index1].name,
                               coordinate: StationPopups[index1].coordinate)
                    {
                        NavigationLink(destination: StationDetailedView(stationObj: StationPopups[index1].station, trainsViewModel: trainsViewModel, tripUpdatesViewModel: tripUpdatesViewModel, dateInput: Date())) {
                            Image("StationIcon")
                        }.zIndex(4)
                    }
                }
            }.onReceive(self.trainsViewModel.$trains, perform: { trains in // update markers
                updateTrainPopups(train_data: trains)
                
            })
            Image(systemName: "location.fill").foregroundColor(.white).font(.system(size: 28.0)).padding(12).background(Color.black).position(x: 50, y: 30).onTapGesture {
                let userLocation = manager.location
                loc = CLLocationCoordinate2D(latitude: userLocation?.coordinate.latitude ?? 38.9072, longitude: userLocation?.coordinate.longitude ?? 77.0369)
                span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                position = .region(MKCoordinateRegion(center: loc, span: span))
            }
        }.onAppear {
            for station in getStations() {
                StationPopups.append(StationPopup(coordinate: CLLocationCoordinate2D(latitude: station.stop_lat, longitude: station.stop_lon), name: station.stop_name, station: station))
            }
            updateTrainPopups(train_data: trainsViewModel.trains)
            if suppliedLoc != nil {
                position = .region(MKCoordinateRegion(center: suppliedLoc ?? loc, span: suppliedSpan ?? span))
            } else {
                position = .region(MKCoordinateRegion(center: loc, span: span))
            }
        }
    }
}
    
