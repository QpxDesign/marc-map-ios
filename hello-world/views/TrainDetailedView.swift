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
        center: CLLocationCoordinate2D(latitude:38.9072,longitude:  -77.0369),
    latitudinalMeters: 15000,
    longitudinalMeters: 15000)
    
    let brunswick : [CLLocationCoordinate2D] = getRouteFromFile(filename: "Brunswick")!
    let penn : [CLLocationCoordinate2D] = getRouteFromFile(filename: "Penn")!
    let fred : [CLLocationCoordinate2D] = getRouteFromFile(filename: "FredrickBranch")!
    let camd : [CLLocationCoordinate2D] = getRouteFromFile(filename: "Camden")!

        var body: some View {
            GeometryReader { geometry in
            NavigationView {
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
                        }
                    }
                    if (!details.isEmpty) {
                        MapView(trainCoords: CLLocationCoordinate2D(latitude: details[0].vehicle.position.latitude, longitude: details[0].vehicle.position.longitude), region: region, BrunswickLineCoordinates: brunswick, PennLineCoordinates: penn, CamdenLineCoordinates: camd, FredrickBranchLineCoordinates: fred, tripId: details[0].vehicle.trip.tripId).frame(width:geometry.size.width * 0.90,height:geometry.size.height*0.35).cornerRadius(15)
                    } else {
                        Text("Loading")
                    }
                    
                    Spacer()
                }
                
            }
            
        }
    }
}
