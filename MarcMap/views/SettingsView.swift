//
//  SettingsView.swift
//  MarcMap
//
//  Created by Quinn Patwardhan on 3/5/23.
//
import SwiftUI
import CoreLocation
import StoreKit

@available(iOS 16.0, *)
struct SettingsView: View {
    func getProducts() async -> [Product] {
        return try! await Product.products(for: ["donation2", "donation1", "donation3"])
    }
    @State var userLocation: CLLocation?
    let store = Store()
    @State var products : [Product] = []
   let manager = LocationManager()
  var body: some View {
        
        VStack {
            HeaderView(title:"Info").onAppear() {
                manager.requestLocation()
                userLocation = manager.location
                Task {
                    products = await getProducts()
                }

        
           
            }
            Text("About").bold().font(.system(size:25)).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.leading,15)
            
            HStack {
                Text("Created by").padding(0)
                Link("Quinn Patwardhan",destination: URL(string: "https://quinnpatwardhan.com")!).foregroundColor(Color.blue).padding(0)
            }.frame(maxWidth: .infinity, alignment: .leading).padding(.leading,15).padding(.bottom,1)
            Text("Data Sourced from the Maryland Transit Administration (MTA)").padding(.leading,15).frame(maxWidth: .infinity, alignment: .leading).padding(.bottom,1)
            Link("Privacy Policy",destination: URL(string: "https://marcmap.app/privacy")!).foregroundColor(Color.blue).padding(0).frame(maxWidth: .infinity, alignment: .leading).padding(.leading,15).padding(.bottom,1)
            Text("Made with ❤️ in Maryland").padding(.leading,15).frame(maxWidth: .infinity, alignment: .leading).padding(.bottom,1)
            Text("Donate").font(.system(size: 24, weight: .light)).fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
            Text("Developing and Running MarcMap takes a significant amount of time, effort, and money. To keep MarcMap Free for all, please consider donating below. Any amount is greatly appreciated.").padding(.leading,15).frame(maxWidth: .infinity, alignment: .leading).padding(.bottom,1)

            HStack {
                
                ForEach($products) {
                    $product in
                    ZStack {
                        Button(product.displayPrice) {
                            Task {
                                try await store.purchase(product)
                            }
                        }.font(.system(size: 24)).fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/).padding(15)
                    }
                }}

            Spacer()
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


