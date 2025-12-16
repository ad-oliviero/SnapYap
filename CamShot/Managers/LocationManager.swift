//
//  LocationManager.swift
//  CamShot
//
//  Created by Adriano Oliviero on 16/12/25.
//

import Combine
import CoreLocation
import Foundation

enum LocationError: LocalizedError {
    case restricted
    case denied
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .restricted:
            return "Location access is restricted."
        case .denied:
            return "Location access denied."
        case .unknown:
            return "Location service disabled."
        }
    }
}

final class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    @Published var lastKnownLocation: CLLocationCoordinate2D?
    @Published var locationError: LocationError?
    var manager = CLLocationManager()

    func checkLocationAuthorization() {
        manager.delegate = self
        manager.startUpdatingLocation()
        
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            
        case .restricted:
            locationError = .restricted
            
        case .denied:
            locationError = .denied
            
        case .authorizedAlways:
            break
            
        case .authorizedWhenInUse:
            lastKnownLocation = manager.location?.coordinate
            
        @unknown default:
            locationError = .unknown
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) { // Trigged every time authorization status changes
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastKnownLocation = locations.first?.coordinate
    }
}
