//
//  FooterView.swift
//  MarcMap
//
//  Created by Quinn Patwardhan on 3/5/23.
//

import SwiftUI
import MapKit
import CoreLocation
import CoreLocationUI
import WeatherKit

@available(iOS 16.0, *)
struct FooterView: View {
    @State var currentWeather : CurrentWeather?
    @State var userLocation: CLLocation?
    
    let manager = LocationManager()
    var body: some View {
        HStack {
            Text("Copyright © 2022 Apple Inc. All rights reserved. Apple Weather and Weather are trademarks of Apple Inc.").padding(10).font(.system(size: 14))
            Link("Data Sources ↗",
                 destination: URL(string: "https://weatherkit.apple.com/legal-attribution.html")!).padding(.trailing,10)
            
            
            
            
        } .frame(maxWidth: .infinity, alignment: .leading).background(Color.black).foregroundColor(Color.white)
    }
}
