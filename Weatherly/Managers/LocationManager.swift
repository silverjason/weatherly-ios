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

    private var locationCompletion: ((CLPlacemark?, String?) -> Void)?
    
    private var locationAuthorizationStatus: CLAuthorizationStatus {
        if #available(iOS 14.0, *) {
            return locationManager.authorizationStatus
        } else {
            // Fallback on earlier versions
            return CLLocationManager.authorizationStatus()
        }
    }

    // MARK: - functions
    static func getCurrent(completion: @escaping ((CLPlacemark?, String?) -> Void)) {
        shared.configure()
        shared.locationCompletion = completion
        switch shared.locationAuthorizationStatus{
        case .notDetermined:
            shared.locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            completion(nil, "Please check your location permissions")
        default:
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

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        // Use the last reported location.
        if let lastLocation = locationManager.location {
            let geocoder = CLGeocoder()

            // Look up the location and pass it to the completion handler
            geocoder.reverseGeocodeLocation(lastLocation) { [unowned self] (placemarks, error) in

                if let error = error {
                    print("reverse geocode failed \(error.localizedDescription)")
                    locationCompletion?(nil, error.localizedDescription)

                } else if let placemarks = placemarks,
                          let placemark = placemarks.first {

                    locationCompletion?(placemark, nil)
                }
            }

        } else {
            // No location was available.
            locationCompletion?(nil, "Location could not be determined")
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {

        if locationAuthorizationStatus == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    //MARK: - iOS 13 support
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationManagerDidChangeAuthorization(manager)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location failed \(error.localizedDescription)")
        locationCompletion?(nil, error.localizedDescription)
    }

}
