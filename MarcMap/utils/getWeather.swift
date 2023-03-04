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
    let manager = LocationManager()
    manager.requestLocation()
    var userLocation = manager.location
    let weatherService = WeatherService()
        // Fallback on earlier versions
  
        do {
            let location = userLocation
            let weather = try await weatherService.weather(for: location ?? CLLocation(latitude: 38.9072, longitude: -77.0369))
            print(weather.hourlyForecast.forecast[0].cloudCover)
            return weather.currentWeather
        } catch {
            return nil
        }
   
    }

func CelciusToFahrenheit(C : Double) -> Double {
    return C*(9/5)+32

}
