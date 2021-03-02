//
//  LocationManager.swift
//  Weatherly
//
//  Created by Jason Silver on 26/2/21.
//

import Foundation
import CoreLocation
class LocationManager: NSObject {
    
    // MARK: - instance
    private static let shared = LocationManager()
    
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        return manager
    }()
    
    private var locationCompletion: ((CLPlacemark?) -> Void)?
    
    
    // MARK: - functions
    static func getCurrent(completion: @escaping ((CLPlacemark?) -> Void)) {
        shared.configure()
        shared.locationCompletion = completion
        if shared.locationManager.authorizationStatus == .notDetermined {
            shared.locationManager.requestWhenInUseAuthorization()
        } else {
            shared.locationManager.requestLocation()
        }
    }
    
    // MARK: - Convenience
    private func configure() {
        
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.distanceFilter = kCLDistanceFilterNone
    }
    
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // Use the last reported location.
        if let lastLocation = locationManager.location {
            let geocoder = CLGeocoder()
                
            // Look up the location and pass it to the completion handler
            geocoder.reverseGeocodeLocation(lastLocation) { [unowned self] (placemarks, error) in
                
                if let error = error {
                    print("reverse geocode failed \(error.localizedDescription)")
                    locationCompletion?(nil)
                    
                } else if let placemarks = placemarks,
                          let placemark = placemarks.first {
                    
                    locationCompletion?(placemark)
                }
            }
            
        }
        else {
            // No location was available.
            self.locationCompletion?(nil)
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        if locationManager.authorizationStatus != .notDetermined {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location failed \(error.localizedDescription)")
        locationCompletion?(nil)
    }
    
}
