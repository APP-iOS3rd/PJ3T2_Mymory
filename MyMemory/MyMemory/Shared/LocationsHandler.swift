//
//  LocationsHandler.swift
//  MyMemory
//
//  Created by 정정욱 on 1/18/24.
//

import Foundation
import CoreLocation

// 💁 사용자 위치추적 및 권한허용 싱글톤 구현 위치 임시지정
class LocationsHandler: NSObject, CLLocationManagerDelegate {
    static let shared = LocationsHandler()
    private let locationManager = CLLocationManager()
    var completion: ((CLLocationCoordinate2D?) -> Void)?
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func getCurrentLocation(completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        self.completion = completion
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            completion?(location.coordinate)
        }
        completion?(nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        completion?(nil)
    }
}

