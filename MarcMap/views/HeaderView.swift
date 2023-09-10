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

@available(iOS 16.0, *)
struct HeaderView: View {
    var title : String

    let manager = LocationManager()
    var body: some View {
        HStack {
            Text(title).bold().multilineTextAlignment(.leading).padding(.leading,20).padding(.bottom, 15).foregroundColor(Color.white).font(.system(size: 34)).padding(.top,8)
            Spacer()

            
            
            
            
        } .frame(maxWidth: .infinity, alignment: .leading).background(CustomColors.MarcOrange)
    }
}
