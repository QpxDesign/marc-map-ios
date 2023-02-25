//
//  TaskbarView.swift
//  hello-world
//
//  Created by Quinn Patwardhan on 2/24/23.
//

import Foundation
import SwiftUI

struct Taskbar : View {
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                HStack {
                    
                }.frame(width:geometry.size.width,height:75).background(Color.black)
            }.border(Color.red).frame(maxHeight: 75).padding(.top,150)
        }
    }
}
