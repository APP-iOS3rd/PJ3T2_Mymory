//
//  CLLocation+Extension.swift
//  MyMemory
//
//  Created by 김성엽 on 1/19/24.
//

import CoreLocation

extension CLLocationCoordinate2D {

    func distance(from: CLLocation) -> CLLocationDistance {
        let from = CLLocation(latitude: from.coordinate.latitude, longitude: from.coordinate.longitude)
        let to = CLLocation(latitude: self.latitude, longitude: self.longitude)
        return round(from.distance(from: to))
    }
}

