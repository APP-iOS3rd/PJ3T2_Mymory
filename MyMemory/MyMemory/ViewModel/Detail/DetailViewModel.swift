//
//  DetailViewModel.swift
//  MyMemory
//
//  Created by 정정욱 on 1/29/24.

import SwiftUI
import _PhotosUI_SwiftUI
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import CoreLocation
import KakaoMapsSDK


class DetailViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()

    @Published var myCurrentAddress: String? = nil
    @Published var selectedAddress: String? = nil
    @Published var location: CLLocation?
    
    
    @Published var user: User?
    @Published var memoCreator: User?
    @Published var isCurrentUserLoginState = false
    
    //  let db = Firestore.firestore()
    let memoService = MemoService.shared
    
    @Published var currentLocation: CLLocation?  = nil
    
    override init() {
        super.init()
        // fetchUserState()
        user = AuthService.shared.currentUser // 현 로그인 사용자 가져오기
        AuthService.shared.fetchUser() // 사용자 정보 가져오기
        locationConfig()
        getCurrentAddress()
        
    }
    
    func fetchMemoCreator(uid: String) {
        
        AuthService.shared.memoCreatorfetchUser(uid: uid) { user in
            if let user = user {
                // 성공적으로 유저 정보를 받아온 경우
                self.memoCreator = user
                print("User: \(user)")
            } else {
                // 실패한 경우 또는 에러가 발생한 경우
                
                
                print("Failed to fetch user. Unknown error.")
                
            }
        }
        
        
    }
    
    func fetchUserState() {
        guard let _ = UserDefaults.standard.string(forKey: "userId") else { return }
    }
    
    func fetchCurrentUserLoginState() -> Bool {
        if let _ = Auth.auth().currentUser {
            return true
        }
        return false
    }
    
    
    
}


//MARK: - 초기 Configuration
extension DetailViewModel {
    private func locationConfig() {
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingHeading()
        self.locationManager.startUpdatingLocation()
        self.locationManager.delegate = self
    }
}

//MARK: - Location
extension DetailViewModel {
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
            weakSelf.location = .init(latitude: location.coordinate.latitude,
                                   longitude: location.coordinate.longitude)

            weakSelf.getCurrentAddress()
        }
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
        guard let loc = self.location else { return }
        let point = MapPoint(longitude: loc.coordinate.longitude, latitude: loc.coordinate.latitude)
        Task{@MainActor in
            self.myCurrentAddress = await GetAddress.shared.getAddressStr(location: point)
        }
    }
}
