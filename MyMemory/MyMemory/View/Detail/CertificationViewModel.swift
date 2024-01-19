//
//  CertificationViewModel.swift
//  MyMemory
//
//  Created by 김성엽 on 1/18/24.
//

import SwiftUI
import CoreLocation

class CertificationViewModel: ObservableObject {
    @Published var memoData: [PostMemoModel] = []
    
    //view로 전달할 값 모음
    @Published var memoTitle: String = ""
    @Published var memoContents: String = ""
    @Published var memoAddressText: String = ""
    @Published var memoSelectedImageData: [Data] = []
    @Published var memoSelectedTags: [String] = []
    @Published var memoShare: Bool = false
    @Published var userCoordinate: CLLocationCoordinate2D?
    
    // 사용자 위치 값 가져오기
    var locationsHandler = LocationsHandler.shared
    
    // 사용자의 현재 위치의 위도와 경도를 가져오는 메서드
    
    func getUserCurrentLocation() {
        locationsHandler.getCurrentLocation { [weak self] location in
            DispatchQueue.main.async {
                if let location = location {
                    print("User's current location - Latitude: \(location.latitude), Longitude: \(location.longitude)")
                    self?.userCoordinate = location

                } else {
                    print("Unable to retrieve user's current location.")
                }
            }
        }
    }
    
    init() {
        // ViewModel이 생성될 때 사용자의 현재 위치를 가져오는 메서드를 호출합니다.
        getUserCurrentLocation()
    }
    
}

