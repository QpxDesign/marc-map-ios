//
//  RouteIdToName.swift
//  hello-world
//
//  Created by Quinn Patwardhan on 2/22/23.
//

import Foundation

func RouteIdToName(routeId: String) -> String {
    if (routeId == "11704") {
        return "Brunswick"
    }
    if (routeId == "11705") {
        return "Penn"
    }
    if (routeId == "11706") {
        return "Camden"
    }
    return "Invalid Route"
}

