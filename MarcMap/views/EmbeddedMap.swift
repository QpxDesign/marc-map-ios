//
//  EmbeddedMap.swift
//  MarcMap
//
//  Created by Quinn Patwardhan on 11/2/26.
//

import Foundation
import MapKit
import SwiftUI

struct EmbeddedMap: View {
    let loc: CLLocationCoordinate2D
    let tripId: String
    @State var suppliedSpan: MKCoordinateSpan?
    let stations: [station]

    @ObservedObject var trainsViewModel: TrainsViewModel
    @ObservedObject var tripUpdatesViewModel: TripUpdatesViewModel

    @State private var StationPopups: [StationPopup] = []
    @State private var trainPopup: TrainPopup? = nil
    @State var span: MKCoordinateSpan = .init(latitudeDelta: 0.05, longitudeDelta: 0.05)
    @State private var position: MapCameraPosition = .automatic

    func updateTrainPopups(train_data: [Train]) {
        let matching_train = train_data.filter { $0.vehicle.trip.tripId == self.tripId }
        if matching_train.isEmpty {
            return
        }
        if trainPopup == nil {
            trainPopup = TrainPopup(coordinate: CLLocationCoordinate2D(latitude: matching_train[0].vehicle.position.latitude, longitude: matching_train[0].vehicle.position.longitude), bearing: matching_train[0].vehicle.position.bearing ?? 0, tripID: matching_train[0].vehicle.trip.tripId)
            return
        }

        trainPopup?.coordinate.latitude = matching_train[0].vehicle.position.latitude
        trainPopup?.coordinate.longitude = matching_train[0].vehicle.position.longitude
    }

    let manager = LocationManager()

    var body: some View {
        ZStack {
            Map(position: $position) {
                MapPolyline(coordinates: getRouteFromFile(filename: "Brunswick") ?? [CLLocationCoordinate2D(latitude: 0, longitude: 0)]).stroke(CustomColors.BrunswickColor, lineWidth: 10.0)
                MapPolyline(coordinates: getRouteFromFile(filename: "FredrickBranch") ?? [CLLocationCoordinate2D(latitude: 0, longitude: 0)]).stroke(CustomColors.BrunswickColor, lineWidth: 10.0)

                MapPolyline(coordinates: getRouteFromFile(filename: "Penn") ?? [CLLocationCoordinate2D(latitude: 0, longitude: 0)]).stroke(CustomColors.PennColor, lineWidth: 10.0)
                MapPolyline(coordinates: getRouteFromFile(filename: "Camden") ?? [CLLocationCoordinate2D(latitude: 0, longitude: 0)]).stroke(CustomColors.CamdenColor, lineWidth: 10.0)

                if trainPopup != nil {
                    Annotation("",
                               coordinate: trainPopup?.coordinate ?? CLLocationCoordinate2D(latitude: 38.894, longitude: -77.029))
                    {
                        NavigationLink(destination: TrainDetailedView(tripId: trainPopup?.tripID ?? "", stations: stations, trainsViewModel: trainsViewModel, tripUpdatesViewModel: tripUpdatesViewModel)) {
                            Image("TrainIcon")
                        }.zIndex(5)
                    }
                }

                ForEach(StationPopups.indices, id: \.self) { index1 in
                    Annotation(StationPopups[index1].name,
                               coordinate: StationPopups[index1].coordinate)
                    {
                        NavigationLink(destination: StationDetailedView(stationObj: StationPopups[index1].station, stations: stations, trainsViewModel: trainsViewModel, tripUpdatesViewModel: tripUpdatesViewModel, dateInput: Date())) {
                            Image("StationIcon")
                        }.zIndex(4)
                    }
                }
            }.onReceive(self.trainsViewModel.$trains, perform: { trains in // update markers
                updateTrainPopups(train_data: trains)

            })
        }.onAppear {
            span = suppliedSpan ?? span

            position = .region(MKCoordinateRegion(center: loc, span: span))
            for station in stations {
                StationPopups.append(StationPopup(coordinate: CLLocationCoordinate2D(latitude: station.stop_lat, longitude: station.stop_lon), name: station.pretty_stop_name, station: station))
            }

            updateTrainPopups(train_data: trainsViewModel.trains)
        }
    }
}
