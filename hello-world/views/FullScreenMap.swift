//
//  FullScreenMap.swift
//  hello-world
//
//  Created by Quinn Patwardhan on 2/24/23.
//

import Foundation
import SwiftUI
import MapKit

struct FullScreenMap: View {
    var tripId: String
    @State var trains: [Train]
    
    @State var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude:38.9072, longitude:  -77.0369),
        latitudinalMeters: 50_000,
        longitudinalMeters: 50_000)
    let brunswick : [CLLocationCoordinate2D] = getRouteFromFile(filename: "Brunswick")!
    let penn : [CLLocationCoordinate2D] = getRouteFromFile(filename: "Penn")!
    let fred : [CLLocationCoordinate2D] = getRouteFromFile(filename: "FredrickBranch")!
    let camd : [CLLocationCoordinate2D] = getRouteFromFile(filename: "Camden")!
    var body: some View {
        

            GeometryReader { geometry in
                MapView(region: region, BrunswickLineCoordinates: brunswick, PennLineCoordinates: penn, CamdenLineCoordinates: camd, FredrickBranchLineCoordinates: fred, trains: trains, tripId:tripId).padding(.bottom, 0).edgesIgnoringSafeArea(.all)
                }
                  
                
        
            
        
    }
}
