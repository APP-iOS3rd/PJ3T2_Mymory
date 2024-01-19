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

final class MainMapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let operation: OperationQueue = OperationQueue()
    private var startingClusters: [MemoCluster] = []
    
    @Published var filterList: Set<String> = Set() {
        didSet {
            filteredMemoList = MemoList.filter{ [weak self] memo in
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
    @Published var MemoList: [Memo] = []
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
    }
    private func tempModel() {
        self.MemoList = [
            Memo(title: "ggg", description: "gggg", address: "서울시 @@구 @@동", tags: ["ggg", "Ggggg"], images: [], isPublic: false, date: Date().timeIntervalSince1970 - 1300, location: Location(latitude: 37.402101, longitude: 127.108478), likeCount: 10),
            Memo(title: "ggg", description: "gggg", address: "서울시 @@구 @@동", tags: ["ggg", "Ggggg"], images: [], isPublic: false, date: Date().timeIntervalSince1970 - 3300, location: Location(latitude: 37.402201, longitude: 127.108578), likeCount: 10),
            Memo(title: "ggg", description: "gggg", address: "서울시 @@구 @@동", tags: ["ggg", "Ggggg"], images: [], isPublic: false, date: Date().timeIntervalSince1970 - 100, location: Location(latitude: 37.402301, longitude: 127.108678), likeCount: 10),
            Memo(title: "ggg", description: "gggg", address: "서울시 @@구 @@동", tags: ["ggg", "Ggggg"], images: [], isPublic: false, date: Date().timeIntervalSince1970 + 200, location: Location(latitude: 37.402401, longitude: 127.108778), likeCount: 10),
            Memo(title: "ggg", description: "gggg", address: "서울시 @@구 @@동", tags: ["ggg", "Ggggg"], images: [], isPublic: false, date: Date().timeIntervalSince1970, location: Location(latitude: 37.402501, longitude: 127.108878), likeCount: 10),
        ]
        self.startingClusters = initialCluster()
    }
    
    func fetchMemos() {
        Task {
            do {
                MemoList = try await MemoService.shared.fetchMemos()
                // 테이블 뷰 리로드 또는 다른 UI 업데이트
                self.startingClusters = initialCluster()

            } catch {
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
            MemoList.sort(by: {$0.location.distance(from: location) < $1.location.distance(from: location)})
            filteredMemoList.sort(by: {$0.location.distance(from: location) < $1.location.distance(from: location)})
        } else {
            MemoList.sort(by: {$0.date < $1.date})
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
            print(self.myCurrentAddress)
        }
    }
}
//MARK: - Clustering 관련 Logics
extension MainMapViewModel {
    func switchUserLocation() {
        if !self.isUserTracking {
            self.isUserTracking = true
        }
    }
    private func calculateDistance(from clusters: [MemoCluster], threshold: Double) -> [MemoCluster] {
        var tempClusters = clusters
        var i = 0, j = 0
        while(i < tempClusters.count) {
            j = i + 1
            while(j < tempClusters.count) {
                let distance = tempClusters[i].center.distance(to: tempClusters[j].center) * 5000000
                if distance < threshold {
                    if selectedCluster?.id == tempClusters[j].id {
                        tempClusters[i].id = tempClusters[j].id
                    }
                    tempClusters[i].updateCenter(with: tempClusters[j])
                    tempClusters.remove(at: j)
                    j -= 1
                }
                j += 1
            }
            i += 1
        }
        if tempClusters == clusters {
            return clusters
        }
        return tempClusters
    }
    
    // 오류나서 일단 주석
//    private func initialCluster() -> [MemoCluster] {
//        return self.MemoList.map{.init(memo: $0)}
//    }
    private func cluster(distance: Double) -> [MemoCluster] {
        let result = calculateDistance(from: startingClusters, threshold: distance)
        return result
    }
    func updateAnnotations(cameraDistance: Double){
        operation.cancelAllOperations()
        operation.addOperation { [weak self] in
            self?.clusters = self?.cluster(distance: cameraDistance) ?? []
        }
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


// Marker 생성로직

