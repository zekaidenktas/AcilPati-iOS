//
//  LocationManager.swift
//  Acil Pati
//
//  Created by Zekai Denktaş on 26.11.2025.
//

import Foundation
import CoreLocation
import Combine 

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    private let manager = CLLocationManager()
    @Published var userLocation: CLLocationCoordinate2D?
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        
        if let location = locations.last {
            userLocation = location.coordinate
        }
        
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways{
            manager.startUpdatingLocation( )
            
        }
    }
}
