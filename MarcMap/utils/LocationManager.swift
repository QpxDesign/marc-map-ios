//
//  LocationManager.swift
//  hello-world
//
//  Created by Quinn Patwardhan on 2/25/23.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()

    @Published var location: CLLocation?

    override init() {
        super.init()
        manager.delegate = self
    }

    func requestLocation() {
        manager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Swift.Error) {
            print("error:: \(error)")
        }
        
        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            if status == CLAuthorizationStatus.authorizedWhenInUse
                || status == CLAuthorizationStatus.authorizedAlways {
                manager.requestLocation()
            }
            else{
                //other procedures when location service is not permitted.
                if CLLocationManager.locationServicesEnabled() {
                    switch manager.authorizationStatus {
                    case .notDetermined:
                        manager.requestWhenInUseAuthorization()
                    case .restricted, .denied:
                        // Show an alert letting the user know they need to enable location services
                        print("location denied")
                        break
                    case .authorizedAlways, .authorizedWhenInUse:
                        print("location allowed")
                        // Do nothing
                        break
                    @unknown default:
                        fatalError()
                    }
                } else {
                    // Show an alert letting the user know they need to enable location services
                }
            }
        }
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            print("Did update location called")
    //        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
            if locations.first != nil {
                location = locations.first
            }
            
        }
}

