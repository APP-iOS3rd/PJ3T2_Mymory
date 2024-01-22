//
//  CertificationViewModel.swift
//  MyMemory
//
//  Created by 김성엽 on 1/19/24.
//

import SwiftUI
import CoreLocation
import Combine
import MapKit
import KakaoMapsSDK
import CoreLocation
import AppTrackingTransparency

final class CertificationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()

    //view로 전달할 값 모음
    @Published var myCurrentAddress: String? = nil
    @Published var direction: Double = 0
    @Published var targetLocation = CLLocation(latitude: 35.8551, longitude: 128.5098)
    @Published var draw: Bool = true
    @Published var selectedAddress: String? = nil
    @Published var userCoordinate: CLLocation?
  
    override init() {
        super.init()
//        ATTrackingManager.requestTrackingAuthorization { status in
//            switch status {
//            case .authorized:
//                print("authorized")
//                self.locationConfig()
//            case .notDetermined:
//                print("notDetermined")
//                self.locationConfig()
//            case .restricted:
//                print("restricted")
//                self.locationConfig()
//            case .denied:
//                print("denied")
//                self.locationConfig()
//            @unknown default:
//                self.locationConfig()
//            }
//        }
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
            print("authorizedAlways")
            locationConfig()
        case .notDetermined:
            print("notDetermined")
            locationConfig()
        case .restricted:
            print("restricted")
            locationConfig()
        case .denied:
            print("denied")
            locationConfig()
        case .authorizedWhenInUse:
            print("authorizedWhenInUse")
            locationConfig()
        @unknown default:
            locationConfig()
        }
        
        getCurrentAddress()
    }
    
}


//MARK: - 초기 Configuration
extension CertificationViewModel {
    private func locationConfig() {
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest// 정확도 설정
        self.locationManager.requestAlwaysAuthorization() // 권한 요청
        self.locationManager.startUpdatingHeading()
        self.locationManager.startUpdatingLocation() // 위치 업데이트 시작
        self.locationManager.delegate = self
    }
}
//MARK: - Location
extension CertificationViewModel {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined, .restricted, .denied:
            locationManager.requestAlwaysAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            print("넘어가기")
        @unknown default:
            locationManager.requestAlwaysAuthorization()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async { [weak self] in
            guard let weakSelf = self else {return}
            weakSelf.userCoordinate = .init(latitude: location.coordinate.latitude,
                                   longitude: location.coordinate.longitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        direction = newHeading.trueHeading * Double.pi / 180.0
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("failed")
    }
    
    //MARK: - 주소 얻어오는 함수
    //특정 selected 위치 주소값
    private func getAddressFromCoordinates(latitude: Double, longitude: Double) {
        Task{@MainActor in
            self.selectedAddress = await GetAddress.shared.getAddressStr(location: .init(longitude: longitude, latitude: latitude))
        }
    }
    
    //user location주소값
    func getCurrentAddress() {
        guard let loc = self.userCoordinate else { return }
        let point = MapPoint(longitude: loc.coordinate.longitude, latitude: loc.coordinate.latitude)
        Task{@MainActor in
            self.myCurrentAddress = await GetAddress.shared.getAddressStr(location: point)
        }
    }
}



