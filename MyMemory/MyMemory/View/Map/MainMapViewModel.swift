//
//  MainMapViewModel.swift
//  MyMemory
//
//  Created by 김태훈 on 1/2/24.
//

import Foundation
import Combine
import MapKit
import KakaoMapsSDK
import CoreLocation

final class MainMapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate, PGClusteringManagerDelegate {

    
    private let locationManager = CLLocationManager()
    private let operation: OperationQueue = OperationQueue()
    private let cluster: ClusterOperation = .init()
    
    
    @Published var filterList: Set<String> = Set() {
        didSet {
            filteredMemoList = memoList.filter{ [weak self] memo in
                guard let self = self else { return false }
                if self.filterList.isEmpty { return true }
                var preset = false
                for f in self.filterList {
                    preset = memo.tags.contains(f) || preset
                }
                return preset
            }
        }
    }
    
    @Published var location: CLLocation?
    @Published var direction: Double = 0
    @Published var myCurrentAddress: String? = nil
    @Published var filteredMemoList: [Memo] = []
    @Published var memoList: [Memo] = []
    @Published var isUserTracking: Bool = true
    @Published var clusters: [MemoCluster] = []
    @Published var searchTxt: String = ""
    @Published var selectedMemoId: UUID? = nil
    @Published var selectedCluster: MemoCluster? = nil{
        didSet {
            guard let cluster = selectedCluster else {
                selectedAddress = nil
                return
            }
            let latitude = cluster.center.latitude
            let longitude = cluster.center.longitude
            getAddressFromCoordinates(latitude: latitude, longitude: longitude)
            selectedMemoId = cluster.memos.first?.id
        }
    }
    @Published var selectedAddress: String? = nil 
    @Published var clusteringDidChanged: Bool = true
    
    
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
        fetchMemos()
        getCurrentAddress()
        self.cluster.delegate = self
    }
    
    func fetchMemos() {
        LoadingManager.shared.phase = .loading
        Task { @MainActor in 
            do {
                let fetched = try await MemoService.shared.fetchMemos()
                // 테이블 뷰 리로드 또는 다른 UI 업데이트
                // 특정 distance 이내의 것만 사용하기
                if let current = location {
                    memoList = fetched.filter{$0.location.distance(from: current) < 1000}
                    
                } else {
                    memoList = fetched
                }
                cluster.addMemoList(memos: memoList)
                LoadingManager.shared.phase = .success
            } catch {
                LoadingManager.shared.phase = .fail(msg: error.localizedDescription)
                print("Error fetching memos: \(error)")
            }
        }
    }
}
//MARK: - 초기 Configuration
extension MainMapViewModel {
    private func locationConfig() {
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest // 정확도 설정
        self.locationManager.requestAlwaysAuthorization() // 권한 요청
        self.locationManager.startUpdatingHeading()
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
            weakSelf.getCurrentAddress()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        direction = newHeading.trueHeading * Double.pi / 180.0
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("failed")
    }
    //MARK: - View Controll logic
    
    func sortByDistance(_ distance: Bool) {
        if distance {
            guard let location = location else { return }
            memoList.sort(by: {$0.location.distance(from: location) < $1.location.distance(from: location)})
            filteredMemoList.sort(by: {$0.location.distance(from: location) < $1.location.distance(from: location)})
        } else {
            memoList.sort(by: {$0.date < $1.date})
            filteredMemoList.sort(by: {$0.date < $1.date})
        }
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
//MARK: - Clustering 관련 Logics
extension MainMapViewModel {
    func displayClusters(clusters: [MemoCluster]) {
        if clusters != self.clusters {
            self.clusters = clusters
            clusteringDidChanged = true
        } else {
            clusteringDidChanged = false
        }
    }
    
    func switchUserLocation() {
        if !self.isUserTracking {
            self.isUserTracking = true
        }
    }
    // 오류나서 일단 주석
    func clusterTest(mapRect: AreaRect, zoomScale: Int) {
        cluster.clusterMemosWithMapRect(cameraRect: mapRect, zoomScale: zoomScale)
    }
}
extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return abs(lhs.latitude - rhs.latitude) < 0.0001 && abs(lhs.longitude - rhs.longitude) < 0.0001
    }

    func squaredDistance(to : CLLocationCoordinate2D) -> Double {
        return (self.latitude - to.latitude) * (self.latitude - to.latitude) + (self.longitude - to.longitude) * (self.longitude - to.longitude)
    }
    

    func distance(to: CLLocationCoordinate2D) -> Double {
        return sqrt(squaredDistance(to: to))
    }
}



