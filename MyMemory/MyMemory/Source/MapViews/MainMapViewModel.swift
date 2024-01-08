//
//  MainMapViewModel.swift
//  MyMemory
//
//  Created by 김태훈 on 1/2/24.
//

import Foundation
import Combine
import MapKit
final class MainMapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var location: CLLocation?
    @Published var region: MKCoordinateRegion?
    @Published var annotations: [MiniMemoModel] = []
    @Published var isUserTracking: Bool = true
    override init() {
        super.init()
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
        configuration()
        tempModel()
    }
    private func tempModel() {
        self.annotations = [.init(coordinate: .init(latitude: 37.5665,
                                                    longitude: 126.9780),
                                     title: "test1",
                                     contents: "contents2",
                                     images: [],
                                  createdAt: Date().timeIntervalSince1970),
                            .init(coordinate: .init(latitude: 37.5665,
                                                    longitude: 126.979),
                                                         title: "test2",
                                                         contents: "contents2",
                                                         images: [],
                                                      createdAt: Date().timeIntervalSince1970),
                            .init(coordinate: .init(latitude: 37.5665,
                                                    longitude: 126.980),
                                                         title: "test3",
                                                         contents: "contents2",
                                                         images: [],
                                                      createdAt: Date().timeIntervalSince1970)]
    }
}
//MARK: - 초기 Configuration
extension MainMapViewModel {
    private func configuration() {
        self.location = .init(latitude: 37.5665,
                                longitude: 126.9780) // 서울
        guard let lat = self.location?.coordinate.latitude,
              let long = self.location?.coordinate.longitude else { return }
        let initialCoordinate = CLLocationCoordinate2D(latitude: lat,
                                                       longitude: long)
        let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        DispatchQueue.main.async {
            self.region = MKCoordinateRegion(center: initialCoordinate, span: span)
        }
    }
    private func locationConfig() {
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest // 정확도 설정
        self.locationManager.requestAlwaysAuthorization() // 권한 요청
        self.locationManager.startUpdatingLocation() // 위치 업데이트 시작
        self.locationManager.delegate = self
    }
}
//MARK: - Location
extension MainMapViewModel {
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
//            if weakSelf.location?.distance(from: location) ?? 10 > 10.0 {} // 새 중심과의 거리
            weakSelf.location = .init(latitude: location.coordinate.latitude,
                                   longitude: location.coordinate.longitude)
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("failed")
    }
}
//MARK: - view 관련 Logics
extension MainMapViewModel {
    func switchUserLocation() {
        if !self.isUserTracking {
            self.isUserTracking = true
        }
    }
}
