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
    @ObservedObject var locationViewModel: LocationViewModel
    @ObservedObject var masterViewModel: MasterViewModel

    let tripId: String

    @State var suppliedSpan: MKCoordinateSpan?

    @State private var StationPopups: [StationPopup] = []
    @State private var TrainPopups: [TrainPopup] = []
    @State var span: MKCoordinateSpan = .init(latitudeDelta: 0.05, longitudeDelta: 0.05)
    @State private var position: MapCameraPosition = .automatic

    @State private var brunswickRoute: [CLLocationCoordinate2D] = []
    @State private var fredrickRoute: [CLLocationCoordinate2D] = []
    @State private var pennRoute: [CLLocationCoordinate2D] = []
    @State private var camdenRoute: [CLLocationCoordinate2D] = []

    @State private var stations: [station] = loadStations()

    func updateTrainPopups() {
        // remove old popups
        var new: [TrainPopup] = []
        for t in masterViewModel.data {
            new.append(TrainPopup(trainData: t))
        }
        TrainPopups = new
    }

    let manager = LocationManager()

    var body: some View {
        ZStack {
            Map(position: $position) {
                MapPolyline(coordinates: brunswickRoute)
                    .stroke(CustomColors.BrunswickColor, lineWidth: 10)

                MapPolyline(coordinates: fredrickRoute)
                    .stroke(CustomColors.BrunswickColor, lineWidth: 10)

                MapPolyline(coordinates: pennRoute)
                    .stroke(CustomColors.PennColor, lineWidth: 10)

                MapPolyline(coordinates: camdenRoute)
                    .stroke(CustomColors.CamdenColor, lineWidth: 10)
                ForEach(TrainPopups) { popup in
                    Annotation("",
                               coordinate: CLLocationCoordinate2D(latitude: popup.trainData.position.latitude, longitude: popup.trainData.position.longitude))
                    {
                        NavigationLink(destination: TrainDetailedView(masterViewModel: masterViewModel, data: popup.trainData)) {
                            ZStack {
                                // .offset(x: -10.0, y: -10.0)
                                Image("TrainIcon").rotationEffect(
                                    Angle(degrees: (popup.trainData.position.bearing ?? 90) - 90)
                                )
                            }
                        }
                    }
                }

                ForEach(StationPopups.indices, id: \.self) { index1 in
                    Annotation(StationPopups[index1].name,
                               coordinate: StationPopups[index1].coordinate)
                    {
                        NavigationLink(destination: ContentView()) {
                            Image("StationIcon")
                        }.zIndex(4)
                    }
                }
            }.onReceive(self.locationViewModel.$loc, perform: { new_loc in //
                position = .region(MKCoordinateRegion(center: new_loc, span: span))
            }).onReceive(self.masterViewModel.$data, perform: { _ in //
                updateTrainPopups()
            })

        }.onAppear {
            span = suppliedSpan ?? span

            brunswickRoute = getRouteFromFile(filename: "Brunswick") ?? []
            fredrickRoute = getRouteFromFile(filename: "FredrickBranch") ?? []
            pennRoute = getRouteFromFile(filename: "Penn") ?? []
            camdenRoute = getRouteFromFile(filename: "Camden") ?? []

            position = .region(MKCoordinateRegion(center: locationViewModel.loc, span: span))
            for station in stations {
                StationPopups.append(StationPopup(coordinate: CLLocationCoordinate2D(latitude: station.stop_lat, longitude: station.stop_lon), name: station.pretty_stop_name, station: station))
            }

            //     updateTrainPopups(train_data: masterViewModel.trains)
        }
    }
}
