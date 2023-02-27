//
//  HeaderView.swift
//  MarcMap
//
//  Created by Quinn Patwardhan on 2/27/23.
//

import SwiftUI
import MapKit
import CoreLocation
import CoreLocationUI
import WeatherKit

@available(iOS 16.0, *)
struct HeaderView: View {
    var title : String
    @State var currentWeather : CurrentWeather?
    @State var userLocation: CLLocation?
    
    let manager = LocationManager()
    var body: some View {
        HStack {
            Text(title).bold().multilineTextAlignment(.leading).padding(.leading,20).padding(.bottom, 15).foregroundColor(Color.white).font(.system(size: 34)).padding(.top,8).onAppear() {
                Task {
                    self.currentWeather =  await getWeather()
                }
            }
            Spacer()
            HStack {
                Image(systemName: ((currentWeather?.symbolName ?? "icloud.slash") + ".fill") ?? "icloud.slash").foregroundColor(Color.white)
                Text(String(Int(floor(CelciusToFahrenheit(C: currentWeather?.apparentTemperature.value ?? 0))))+"° F").bold().font(.system(size: 20)).foregroundColor(Color.white)
            }.padding(.trailing,25)
            
            
            
            
        } .frame(maxWidth: .infinity, alignment: .leading).background(CustomColors.MarcOrange)
    }
}
