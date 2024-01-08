//
//  MemoModel.swift
//  MyMemory
//
//  Created by 김태훈 on 1/7/24.
//

import Foundation
import MapKit
struct MiniMemoModel {
    let coordinate: CLLocationCoordinate2D
    let title: String
    let contents: String
    let images: [UIImage]
    let createdAt: TimeInterval
}

