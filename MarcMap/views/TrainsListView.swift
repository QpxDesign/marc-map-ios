//
//  TrainsListView.swift
//  hello-world
//
//  Created by Quinn Patwardhan on 2/22/23.
//

import CoreLocation
import Foundation
import StoreKit
import SwiftUI

struct SectionHeader: View {
    let icon_name: String
    let title_text: String

    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: icon_name).padding(0).font(.system(size: 23))
            Text(title_text).frame(maxWidth: .infinity, alignment: .leading).font(.system(size: 26, weight: .semibold)).padding(.leading, -2).padding(.bottom, -5).multilineTextAlignment(.leading).monospaced().kerning(-1.5)
        }.padding(.leading, 6)
    }
}

struct TrainsListView: View {
    let stations: [station]
    @ObservedObject var trainsViewModel: TrainsViewModel
    @ObservedObject var tripUpdatesViewModel: TripUpdatesViewModel
    @State var showDonateAlert: Bool = false
    @Environment(\.requestReview) private var requestReview

    let manager = LocationManager()

    var body: some View {
        VStack(alignment: .leading) {
            HeaderView(title: "Trains")
            if trainsViewModel.isLoading || tripUpdatesViewModel.isLoading {
                Text("Loading...").padding(.top, 10).font(.system(size: 28, weight: .light)).multilineTextAlignment(.center).frame(maxWidth: .infinity)
                Spacer()
            } else if !trainsViewModel.trains.isEmpty && !tripUpdatesViewModel.tripUpdates.isEmpty {
                ScrollView {
                    VStack(spacing: 0) {
                        VStack {
                            //    SectionHeader(icon_name: "star.fill", title_text: "Favorites").padding(.top, 12)
                            TrainList(stations: stations, trainsViewModel: trainsViewModel, tripUpdatesViewModel: tripUpdatesViewModel, favoritesOnly: true).padding(.bottom, 12)
                        }
                        VStack {
                            //   SectionHeader(icon_name: "lightrail", title_text: "Tracked Trains").padding(.top, 12)
                            TrainList(stations: stations, trainsViewModel: trainsViewModel, tripUpdatesViewModel: tripUpdatesViewModel, favoritesOnly: false)
                        }

                        Spacer()
                    }
                }
                // Text("Favorite").frame(maxWidth: .infinity, alignment: .leading).font(.system(size: 22, weight: .light, design: .rounded)).padding(.leading, 20).padding(.bottom, 0).multilineTextAlignment(.leading)

            } else {
                Text("No Trains Found").padding(.top, 10).font(.system(size: 28, weight: .light)).multilineTextAlignment(.center).frame(maxWidth: .infinity)
                Spacer()
            }
        }
        .alert("Please Donate", isPresented: $showDonateAlert) {
            Button {
                showDonateAlert = false
            } label: {
                Text("No Thanks.")
            }
            NavigationLink(destination: SettingsView()) {
                Button {} label: {
                    Text("Donate")
                }
            }

        } message: {
            Text("To keep MarcMap free and adless for all, please consider donating to help cover developmental costs. Any bit helps.")
        }
        .onAppear {
            Task {
                for await verificationResult in Transaction.updates {
                    UserDefaults.standard.set(verificationResult.jwsRepresentation, forKey: "purchaseJWT")
                }
            }
            let count = UserDefaults.standard.integer(forKey: "processCompletedCountKey")
            UserDefaults.standard.set(count + 1, forKey: "processCompletedCountKey")
            if count == 16 {
                Task { @MainActor in
                    requestReview()
                }
            }
            if count % 19 == 0 && (UserDefaults.standard.string(forKey: "purchaseJWT") == "" || UserDefaults.standard.string(forKey: "purchaseJWT") == nil) {
                showDonateAlert = true
            }
        }
    }
}

#Preview("Content View") {
    ContentView()
}
