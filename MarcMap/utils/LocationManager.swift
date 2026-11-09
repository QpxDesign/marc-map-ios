//
//  LocationManager.swift
//  hello-world
//
//  Created by Quinn Patwardhan on 2/25/23.
//

import CoreLocation
import Foundation

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
        // print("error:: \(error)")
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse
            || status == CLAuthorizationStatus.authorizedAlways
        {
            manager.requestLocation()
        } else {
            // other procedures when location service is not permitted.
            DispatchQueue.global().async {
                if CLLocationManager.locationServicesEnabled() {
                    switch manager.authorizationStatus {
                    case .notDetermined:
                        manager.requestWhenInUseAuthorization()
                    case .restricted, .denied:
                        // Show an alert letting the user know they need to enable location services
                        break
                    case .authorizedAlways, .authorizedWhenInUse:
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
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        if locations.first != nil {
            location = locations.first
        }
    }
}
