//
//  getWeather.swift
//  MarcMap
//
//  Created by Quinn Patwardhan on 2/26/23.
//

import Foundation
import WeatherKit
import CoreLocation

@available(iOS 16.0, *) 
func getWeather() async -> CurrentWeather? {
    let weatherService = WeatherService()
        // Fallback on earlier versions

        do {
            let location = CLLocation(latitude:38.9072, longitude:  -77.0369)
            let weather = try await weatherService.weather(for: location)
            print(weather.currentWeather)
            return weather.currentWeather
        } catch {
            print(error.localizedDescription)
            return nil
        }
   
    }

func CelciusToFahrenheit(C : Double) -> Double {
    return C*(9/5)+32

}
