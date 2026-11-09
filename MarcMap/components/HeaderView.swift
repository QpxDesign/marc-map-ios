//
//  HeaderView.swift
//  MarcMap
//
//  Created by Quinn Patwardhan on 2/27/23.
//

import CoreLocation
import CoreLocationUI
import MapKit
import SwiftUI

struct HeaderView: View {
    var title: String
    /// centralize these three across all headers
    @ObservedObject var headerViewModel: HeaderViewModel

    // .padding(.top, -top_adjustment)
    let manager = LocationManager()
    var body: some View {
        ZStack {
            Text(title).bold().multilineTextAlignment(.leading).padding(.leading, 15).padding(.bottom, 5).foregroundColor(Color.white).font(.system(size: 40, design: .rounded)).fontWeight(.bold).padding(.top, -headerViewModel.top_adjustment)
        }.onGeometryChange(for: CGRect.self) { proxy in
            proxy.frame(in: .global)
        } action: { newValue in
            headerViewModel.prev.append(newValue.origin.y)

            if headerViewModel.prev.count > 1 {
                let c = headerViewModel.prev.count
                let ta = abs(headerViewModel.prev[c - 1] - headerViewModel.prev[c - 2])
                if ta != headerViewModel.top_adjustment && headerViewModel.top_adjustment < 100 {
                    print("Adjusting... \(headerViewModel.top_adjustment)")
                }
                let n = max(headerViewModel.top_adjustment, ta)
                if n < 100 {
                    headerViewModel.top_adjustment = n
                } // max adjustment
            }
            if headerViewModel.prev.count == 1 {
                headerViewModel.initial_top = newValue.origin.y
                print("Initial Top : \(headerViewModel.initial_top)")
            }

            print("Top Adjustment: \(headerViewModel.top_adjustment)")
            print("Frame is now \(newValue)")
            print("Frame is now \(newValue.origin.y) (origin y)")

        }.frame(maxWidth: .infinity, alignment: .leading).padding(.top, 15).padding(.bottom, 0).padding(.leading, 10).background(CustomColors.MarcOrange)

        // changed topPadding for duo (20 -> 40)
    }
}

#Preview("Content View") {
    ContentView()
}
