//
//  SettingsView.swift
//  MarcMap
//
//  Created by Quinn Patwardhan on 3/5/23.
//
import StoreKit
import SwiftUI

@available(iOS 16.0, *)
struct SettingsView: View {
    func getProducts() async -> [Product] {
        return try! await Product.products(for: ["donation2", "donation1", "donation3"])
    }

    let store = Store()
    @State var products: [Product] = []
    var body: some View {
        VStack {
            HeaderView(title: "Info")
            ScrollView {
                HStack {
                    Text("Created by").padding(0).padding(.top, 10)
                    Link("Quinn Patwardhan", destination: URL(string: "https://quinnpatwardhan.com")!).foregroundColor(Color.blue).padding(0).padding(.top, 10)
                }.onAppear {
                    Task {
                        products = await getProducts()
                    }
                }.frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 15).padding(.bottom, 1)
                Text("Please email marc_map_contact @ proton.me if you encounter any issues or have any feedback!").padding(.leading, 15).frame(maxWidth: .infinity, alignment: .leading).padding(.bottom, 1)
                Text("Made with ❤️ in Maryland").padding(.leading, 15).frame(maxWidth: .infinity, alignment: .leading)
                Text("Reset Favorites").foregroundColor(Color.blue).frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 15).padding(.top, 1).onTapGesture {
                    resetFavorites()
                }
                Link("Privacy Policy", destination: URL(string: "https://marcmap.app/privacy")!).foregroundColor(Color.blue).padding(0).frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 15).padding(.bottom, 1)

                Text("Donate").font(.system(size: 32, weight: .light)).fontWeight(/*@START_MENU_TOKEN@*/ .bold/*@END_MENU_TOKEN@*/).padding(.top, 5)
                Text("Developing and Running MarcMap takes a significant amount of time, effort, and money. To keep MarcMap Free for all, please consider donating below. Any amount is greatly appreciated.").padding(.leading, 15).frame(maxWidth: .infinity, alignment: .leading).padding(.bottom, 1)

                HStack {
                    ForEach($products) {
                        $product in
                        ZStack {
                            Button(product.displayPrice) {
                                _ = Task {
                                    try await store.purchase(product)
                                }
                            }.font(.system(size: 24)).fontWeight(/*@START_MENU_TOKEN@*/ .bold/*@END_MENU_TOKEN@*/).foregroundColor(/*@START_MENU_TOKEN@*/ .blue/*@END_MENU_TOKEN@*/).padding(15)
                        }
                    }
                }
                Text("Hiring?").font(.system(size: 32, weight: .light)).fontWeight(/*@START_MENU_TOKEN@*/ .bold/*@END_MENU_TOKEN@*/).padding(.top, 5)
                Text("I'm a current junior studying Computer Science and Media Arts & Culture at Occidental College, and I'm very open to any internship opportunities. I built this my junior year of high school, and I've done a lot since! Check out my portfolio (click on my name above).").padding(.leading, 15).frame(maxWidth: .infinity, alignment: .leading).padding(.bottom, 1)

                Spacer()
            }
        }.frame(maxWidth: .infinity)
    }
}

#Preview("Settings Only") {
    ContentView()
}

#Preview("Full View") {
    ContentView()
}
