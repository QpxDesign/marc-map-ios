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
    @State var top_adjustment = 0.0
    @State var prev: [Double] = []

    // .padding(.top, -top_adjustment)
    let manager = LocationManager()
    var body: some View {
        ZStack {
            Text(title).bold().multilineTextAlignment(.leading).padding(.leading, 15).padding(.bottom, 5).foregroundColor(Color.white).font(.system(size: 40, design: .rounded)).fontWeight(.bold).padding(.top, -top_adjustment)
        }.onGeometryChange(for: CGRect.self) { proxy in
            proxy.frame(in: .global)
        } action: { newValue in
            prev.append(newValue.origin.y)

            if prev.count > 1 && top_adjustment == 0.0 {
                let c = prev.count
                let ta = abs(prev[c - 1] - prev[c - 2])
                top_adjustment = max(top_adjustment, ta)
            }

            print("Top Adjustment: \(top_adjustment)")
            print("Frame is now \(newValue)")
            print("Frame is now \(newValue.origin.y) (origin y)")

        }.frame(maxWidth: .infinity, alignment: .leading).padding(.top, 40).padding(.bottom, 5).padding(.leading, 5).background(CustomColors.MarcOrange)

        // changed topPadding for duo (20 -> 40)
    }
}

#Preview("Content View") {
    ContentView()
}
