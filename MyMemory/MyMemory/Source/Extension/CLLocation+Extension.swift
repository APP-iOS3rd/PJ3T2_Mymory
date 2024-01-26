//
//  CLLocation+Extension.swift
//  MyMemory
//
//  Created by 김성엽 on 1/19/24.
//

import CoreLocation

extension CLLocationCoordinate2D {

    func distance(from: Location) -> CLLocationDistance {
        let from = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let to = CLLocation(latitude: self.latitude, longitude: self.longitude)
        return round(from.distance(from: to))
    }
}



