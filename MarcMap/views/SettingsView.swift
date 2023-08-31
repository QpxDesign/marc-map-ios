//
//  SettingsView.swift
//  MarcMap
//
//  Created by Quinn Patwardhan on 3/5/23.
//
import SwiftUI
import WeatherKit
import CoreLocation

@available(iOS 16.0, *)
struct SettingsView: View {
    @State var currentWeather : CurrentWeather?
    @State var userLocation: CLLocation?
   let manager = LocationManager()
    var body: some View {
        VStack {
            HeaderView(title:"Info").onAppear() {
                manager.requestLocation()
                userLocation = manager.location
            }
            Text("About").bold().font(.system(size:25)).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.leading,15)
            
            HStack {
                Text("Created by").padding(0)
                Link("Quinn Patwardhan",destination: URL(string: "https://quinnpatwardhan.com")!).foregroundColor(Color.blue).padding(0)
            }.frame(maxWidth: .infinity, alignment: .leading).padding(.leading,15).padding(.bottom,1)
            Text("Data Sourced from the Maryland Transit Administration (MTA)").padding(.leading,15).frame(maxWidth: .infinity, alignment: .leading).padding(.bottom,1)
            Link("Privacy Policy",destination: URL(string: "https://marcmap.app/privacy")!).foregroundColor(Color.blue).padding(0).frame(maxWidth: .infinity, alignment: .leading).padding(.leading,15).padding(.bottom,1)
            Text("Made with ❤️ in Maryland").padding(.leading,15).frame(maxWidth: .infinity, alignment: .leading).padding(.bottom,1)
        
            Spacer()
        FooterView()
        }.frame(maxWidth: .infinity)
  
    }
   
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 16.0, *) {
            SettingsView()
        } else {
            // Fallback on earlier versions
        }
    }
}


