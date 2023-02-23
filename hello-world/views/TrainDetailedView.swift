//
//  TrainDetailedView.swift
//  hello-world
//
//  Created by Quinn Patwardhan on 2/22/23.
//
import Foundation
import SwiftUI

struct TrainDetailedView: View {
    var train: Train
    var body: some View {
        HStack {
            Text(train.vehicle.trip.tripId);
        }
    }
}
