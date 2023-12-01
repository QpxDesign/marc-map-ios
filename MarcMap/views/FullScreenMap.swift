//
//  FullScreenMap.swift
//  hello-world
//
//  Created by Quinn Patwardhan on 2/24/23.
//

import Foundation
import SwiftUI
import MapKit
import CoreLocation
import CoreLocationUI

struct FullScreenMap: View {
    
    @StateObject var locationManager = LocationManager()
    var tripId: String
    @State var trains: [Train]
    @State var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude:38.9072, longitude:  -77.0369),
        latitudinalMeters: 50_000,
        longitudinalMeters: 50_000)
    let brunswick : [CLLocationCoordinate2D] = getRouteFromFile(filename: "Brunswick") ?? [CLLocationCoordinate2D(latitude: 0, longitude: 0)]
    let penn : [CLLocationCoordinate2D] = getRouteFromFile(filename: "Penn") ?? [CLLocationCoordinate2D(latitude: 0, longitude: 0)]
    let fred : [CLLocationCoordinate2D] = getRouteFromFile(filename: "FredrickBranch") ?? [CLLocationCoordinate2D(latitude: 0, longitude: 0)]
    let camd : [CLLocationCoordinate2D] = getRouteFromFile(filename: "Camden") ?? [CLLocationCoordinate2D(latitude: 0, longitude: 0)]
    var detailedViewStationId : String = ""
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
         print("Location manager failed with error: \(error.localizedDescription)")
     }

    var body: some View {
            GeometryReader { geometry in
                
                MapView(region: region, BrunswickLineCoordinates: brunswick, PennLineCoordinates: penn, CamdenLineCoordinates: camd, FredrickBranchLineCoordinates: fred, trains: trains, tripId:"tripId" ).padding(.bottom, 0)
        
                          
            }.background(CustomColors.MarcOrange)
    }
}
