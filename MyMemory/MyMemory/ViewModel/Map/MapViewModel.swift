//
//  MapViewModel.swift
//  MyMemory
//
//  Created by 김태훈 on 1/26/24.
//

import Foundation
import Combine
import MapKit
import _MapKit_SwiftUI

final class MapViewModel: ObservableObject {
    @Published var mapPosition = MapCameraPosition.userLocation(fallback: .automatic)
    
}
