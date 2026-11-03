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

@available(iOS 16.0, *)
struct TrainsListView: View {
    // 1.
    @Environment(\.requestReview) private var requestReview
    @ObservedObject private var trainsViewModel = TrainsViewModel()
    @ObservedObject private var tripUpdatesViewModel = TripUpdatesViewModel()

    @State var showDonateAlert: Bool = false

    var body: some View {
        VStack {
            HeaderView(title: "Trains").onReceive(self.trainsViewModel.$trains, perform: { _ in
            }).onReceive(self.tripUpdatesViewModel.$tripUpdates, perform: { _ in
            })
            if trainsViewModel.isLoading || tripUpdatesViewModel.isLoading {
                Text("Loading...").onAppear {
                    print(trainsViewModel.trains)
                }

                Spacer()
            } else if !trainsViewModel.trains.isEmpty && !tripUpdatesViewModel.tripUpdates.isEmpty {
                List(trainsViewModel.trains, id: \.id) { train in
                    VStack(alignment: .leading) {
                        NavigationLink(destination: TrainDetailedView(tripId: train.vehicle.trip.tripId)) {
                            HStack {
                                Text(FormatTripId(tripId: train.vehicle.trip.tripId)).font(.title).fontWeight(.bold)
                                Text(RouteIdToName(routeId: train.vehicle.trip.routeId))

                                // stopTimeUpdate[0].departure?.delay ?? 0) > 300
                                let matching_trip_update = tripUpdatesViewModel.tripUpdates.filter { $0.trip.tripId == train.vehicle.trip.tripId }
                                if !matching_trip_update.isEmpty && (matching_trip_update[0].stopTimeUpdate[0].departure?.delay ?? 0) > 300 {
                                    Rectangle().frame(width: 10, height: 10, alignment: .center).foregroundColor(Color.red).cornerRadius(1000)
                                } else {
                                    Rectangle().frame(width: 10, height: 10, alignment: .center).foregroundColor(Color.green).cornerRadius(1000)
                                }

                                Spacer()
                                HStack(spacing: 0) {
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 24, weight: .light))
                                }
                            }
                        }.navigationLinkIndicatorVisibility(.hidden)
                    }
                }

            } else {
                Text("No Trains Found")
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
            if count % 10 == 0 && (UserDefaults.standard.string(forKey: "purchaseJWT") == "" || UserDefaults.standard.string(forKey: "purchaseJWT") == nil) {
                showDonateAlert = true
            }
        }
    }
}
