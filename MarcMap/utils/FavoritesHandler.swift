//
//  FavoritesHandler.swift
//  MarcMap
//
//  Created by Quinn Patwardhan on 11/3/26.
//

import Foundation

func getFavorites() -> [String] { // returns array of tripids from local storage
    let candidates = (UserDefaults.standard.string(forKey: "favorites") ?? "").split(separator: ",")
    var out: [String] = []
    for candidate in candidates {
        out.append(String(candidate))
    }

    return out
}

func toggleFavorite(favorite: String) {
    var favorites = getFavorites()

    if !favorites.contains(favorite) {
        favorites.append(favorite)
    } else {
        favorites = favorites.filter { $0 != favorite }
    }

    var favorites_str = ""
    for fav in favorites {
        favorites_str += "\(fav),"
    }
    UserDefaults.standard.set(favorites_str, forKey: "favorites")
    print(favorites_str)
}

func resetFavorites() {
    UserDefaults.standard.set("", forKey: "favorites")
}
