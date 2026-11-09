//
//  NewNewMapView.swift
//  MarcMap
//
//  Created by Quinn Patwardhan on 11/29/23.
//

import CoreLocationUI
import Foundation
import Loupe
import MapKit
import SwiftUI

// .ignoresSafeArea(.all).onReceive(self.masterViewModel.$trains, perform: { trains in // update markers updateTrainPopups(train_data: trains)})
/*
 ZStack {
     Map(position: $position, scope: mapScope) {
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
                         Image("TrainIcon").rotationEffect(
                             Angle(degrees: (popup.trainData.position.bearing ?? 90) - 90)
                         )
                     }
                 }
             }
         }
         ForEach(stations) { station in
             Annotation(station.pretty_stop_name,
                        coordinate: CLLocationCoordinate2D(latitude: station.stop_lat, longitude: station.stop_lon))
             {
                 NavigationLink(destination: StationDetailedView(stationObj: station, masterViewModel: masterViewModel, dateInput: Date())) {
                     Image("StationIcon").debugCompute()
                 }.zIndex(4)
             }
         }
     }

 */

struct FullScreenMap: View {
    var stations: [station]
    @StateObject var masterViewModel: MasterViewModel

    @State var suppliedLoc: CLLocationCoordinate2D?
    @State var suppliedSpan: MKCoordinateSpan?
    @State var loc: CLLocationCoordinate2D = .init(latitude: 38.9072, longitude: -77.0369)
    @State var span: MKCoordinateSpan = .init(latitudeDelta: 0.25, longitudeDelta: 0.25)
    @State private var position: MapCameraPosition = .automatic
    @Namespace var mapScope

    @State private var TrainPopups: [TrainPopup] = []
    @State private var StationPopups: [StationPopup] = []

    private let brunswickRoute: [CLLocationCoordinate2D] = getRouteFromFile(filename: "Brunswick") ?? []
    private let fredrickRoute: [CLLocationCoordinate2D] = getRouteFromFile(filename: "FredrickBranch") ?? []
    private let pennRoute: [CLLocationCoordinate2D] = getRouteFromFile(filename: "Penn") ?? []
    private let camdenRoute: [CLLocationCoordinate2D] = getRouteFromFile(filename: "Camden") ?? []

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
            Map(position: $position, scope: mapScope) {
                MapPolyline(coordinates: brunswickRoute)
                    .stroke(CustomColors.BrunswickColor, lineWidth: 10)

                MapPolyline(coordinates: fredrickRoute)
                    .stroke(CustomColors.BrunswickColor, lineWidth: 10)

                MapPolyline(coordinates: pennRoute)
                    .stroke(CustomColors.PennColor, lineWidth: 10)

                MapPolyline(coordinates: camdenRoute)
                    .stroke(CustomColors.CamdenColor, lineWidth: 10)

                StationAnnotations(
                    stations: stations,
                    masterViewModel: masterViewModel
                )

                ForEach(TrainPopups) { popup in
                    Annotation("",
                               coordinate: CLLocationCoordinate2D(latitude: popup.trainData.position.latitude, longitude: popup.trainData.position.longitude))
                    {
                        NavigationLink(destination: TrainDetailedView(masterViewModel: masterViewModel, data: popup.trainData)) {
                            ZStack {
                                Image("TrainIcon").rotationEffect(
                                    Angle(degrees: (popup.trainData.position.bearing ?? 90) - 90)
                                )
                            }
                        }
                    }
                }
            }.onReceive(masterViewModel.$data, perform: { _ in
                updateTrainPopups()
            })

            HStack {
                Image(systemName: "location.fill").foregroundColor(.white).font(.system(size: 28.0)).padding(14).background(CustomColors.MarcBlue).cornerRadius(1000).padding(.bottom, 14).padding(.trailing, 18)
                    .onTapGesture {
                        let userLocation = manager.location
                        loc = CLLocationCoordinate2D(latitude: userLocation?.coordinate.latitude ?? 38.9072, longitude: userLocation?.coordinate.longitude ?? 77.0369)
                        span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                        position = .region(MKCoordinateRegion(center: loc, span: span))
                    }

            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)

        }.onAppear {
            print("adding lines...")
            if suppliedLoc != nil {
                position = .region(MKCoordinateRegion(center: suppliedLoc ?? loc, span: suppliedSpan ?? span))
            } else {
                position = .region(MKCoordinateRegion(center: loc, span: span))
            }
        }
    }
}

#Preview("Content View") {
    ContentView()
}

struct StationAnnotations: MapContent {
    let stations: [station]
    let masterViewModel: MasterViewModel

    var body: some MapContent {
        ForEach(stations) { station in
            Annotation(
                station.pretty_stop_name,
                coordinate: CLLocationCoordinate2D(
                    latitude: station.stop_lat,
                    longitude: station.stop_lon
                )
            ) {
                NavigationLink(
                    destination: StationDetailedView(
                        stationObj: station,
                        masterViewModel: masterViewModel,
                        dateInput: Date()
                    )
                ) {
                    Image("StationIcon")
                }
                .zIndex(4)
            }
        }
    }
}
