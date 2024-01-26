//
//  ClusterBox.swift
//  MyMemory
//
//  Created by 김태훈 on 1/21/24.
//

import Foundation
import KakaoMapsSDK
import CoreLocation

struct ClusterBox {

    let xSouthWest: CGFloat
    let ySouthWest: CGFloat
    let xNorthEast: CGFloat
    let yNorthEast: CGFloat

    static func mapRectToBoundingBox(mapRect: AreaRect) -> ClusterBox {

        let topRight =  mapRect.northEast
        let botLeft = mapRect.southWest

        let minLat = botLeft.wgsCoord.latitude
        let maxLat = topRight.wgsCoord.latitude

        let minLon = botLeft.wgsCoord.longitude
        let maxLon = topRight.wgsCoord.longitude

        return ClusterBox(xSouthWest: CGFloat(minLat),
                             ySouthWest: CGFloat(minLon),
                             xNorthEast: CGFloat(maxLat),
                             yNorthEast: CGFloat(maxLon))
    }

    func containsCoordinate(coordinate: CLLocationCoordinate2D) -> Bool {

        let isContainedInX = self.xSouthWest <= CGFloat(coordinate.latitude) && CGFloat(coordinate.latitude) <= self.xNorthEast
        let isContainedInY = self.ySouthWest <= CGFloat(coordinate.longitude) && CGFloat(coordinate.longitude) <= self.yNorthEast

        return (isContainedInX && isContainedInY)
    }

    func intersectsWithBoundingBox(boundingBox: ClusterBox) -> Bool {

        return (xSouthWest <= boundingBox.xNorthEast && xNorthEast >= boundingBox.xSouthWest &&
            ySouthWest <= boundingBox.yNorthEast && yNorthEast >= boundingBox.ySouthWest)
    }
}
