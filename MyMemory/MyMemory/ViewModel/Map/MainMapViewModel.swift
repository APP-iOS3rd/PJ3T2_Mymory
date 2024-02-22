//
//  MainMapViewModel.swift
//  MyMemory
//
//  Created by 김태훈 on 1/2/24.
//

import Foundation
import SwiftUI
import Combine
import MapKit
import CoreLocation
import _MapKit_SwiftUI
import KakaoMapsSDK
final class MainMapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate, ClusteringDelegate {
    //MARK: - Map, location 관련 프로퍼티
    private var cameraDistance: Double? = nil
    private let locationManager = CLLocationManager()
    private var firstLocationUpdated = false
    private var operationQueue = OperationQueue()

    private var addressOperation: Operation? = nil
    private var fetchOperation: Operation? = nil
    var firstLocation: CLLocation? {
        didSet{
            fetchMemos()
        }
    }    
    var dist: Double = 0

    @Published var mapPosition = MapCameraPosition.userLocation(fallback: .automatic)
    @Published var location: CLLocation? {
        didSet {

            //처음 한번 로케이션 불러오기
            if location != nil {
                fetchOperation?.start()
            }
            if !self.firstLocationUpdated && self.location != nil {
                if let coord = location?.coordinate {
                    self.mapPosition = MapCameraPosition.camera(.init(centerCoordinate: coord, distance: MemoService.shared.queryArea * 5))
                }
                self.firstLocation = self.location
                self.firstLocationUpdated = true
            } else {
                DispatchQueue.main.async {
                    self.dist = self.firstLocation!.distance(from: self.location!)
                    self.isFarEnough = self.dist > 300 // 300미터 이상 갔을 때
                }
            }
        }
    }
    @Published var direction: Double = 0
    @Published var isUserTracking: Bool = true
    @Published var isFarEnough = false
    @Published var mapBoundWidth: Double? = nil
    @Published var currentCameraMapContext: MapCameraUpdateContext? = nil
    //MARK: - Memo, 클러스터링 관련 프로퍼티
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
            cluster.addMemoList(memos: filteredMemoList)
            if let bound = mapBoundWidth,
               let context = currentCameraMapContext {
                self.cameraDidChange(boundWidth: bound, context: context)
            }
        }
    }
    @Published var filteredProfilList: [Profile] = []
    @Published var filteredMemoList: [Memo] = [] {
        didSet {
            self.filteredProfilList = self.memoWriterList.filter{ profile in
                filteredMemoList.contains(where: {$0.userUid == profile.id})
            }
        }
    }
    @Published var memoList: [Memo] = []
    @Published var clusters: [MemoCluster] = []
    @Published var memoWriterList: [Profile] = []
    @Published var selectedMemoId: String? = ""
    @Published var clusteringDidChanged: Bool = true
    //MARK: - 기타 프로퍼티
    @Published var searchTxt: String = ""
    @Published var myCurrentAddress: String? = nil
    @Published var isLoading = false
    @Published var selectedAddress: String? = nil
    @Published var unAuthorized: Bool = false
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
        self.addressOperation = BlockOperation(block: getCurrentAddress)
        self.fetchOperation = BlockOperation(block: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.refreshMemos()
            }
        })
        self.cluster.delegate = self
    }
    func refreshMemos() {
        guard self.location != nil else {
            return
        }
        Task { @MainActor in
            do {
                let fetched = try await MemoService.shared.fetchMemos(in: location)
                // 테이블 뷰 리로드 또는 다른 UI 업데이트
                if let current = location {
                    memoList = fetched.filter{$0.location.distance(from: current) < 1000}
                } else {
                    memoList = fetched
                }
                // 👍 좋아요 누른 메모 체크
                for (index, memo) in memoList.enumerated() {
                    MemoService.shared.checkLikedMemo(memo) { didLike in
                        self.memoList[index].didLike = didLike
                    }
                }
                
                cluster.addMemoList(memos: memoList)
            } catch {
                print("Error fetching memos: \(error)")
            }
        }
    }
    func fetchMemos() {
        isLoading = true
        guard self.location != nil else {
            isLoading = false
            return
        }
        Task { @MainActor in
            do {
                let fetched = try await MemoService.shared.fetchMemos(in: location)
                // 테이블 뷰 리로드 또는 다른 UI 업데이트
                if let current = location {
                    memoList = fetched.filter{$0.location.distance(from: current) < 1000}
                } else {
                    memoList = fetched
                }
                //print("memoList \(memoList)")
                // 👍 좋아요 누른 메모 체크
                for (index, memo) in memoList.enumerated() {
                    MemoService.shared.checkLikedMemo(memo) { didLike in
                        self.memoList[index].didLike = didLike
                    }
                }
                
                cluster.addMemoList(memos: memoList)
                self.fetchMemoProfiles()
                isLoading = false
            } catch {
                isLoading = false
                print("Error fetching memos: \(error)")
            }
        }
    }
    func fetchMemoProfiles() {
        self.isLoading = true
        Task { @MainActor in
            self.memoWriterList = await AuthService.shared.memoCreatorfetchProfiles(memos: memoList)
            self.isLoading = false
        }
    }
    func refreshMemoProfiles() {
//        self.isLoading = true
        Task { @MainActor in
            self.memoWriterList = await AuthService.shared.memoCreatorfetchProfiles(memos: memoList)
//            self.isLoading = false
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
//            weakSelf.getCurrentAddress()
            weakSelf.addressOperation?.start()
        }
        let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] t in
           
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
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            if distance {
                guard let location = location else { return }
                memoList.sort(by: {$0.location.distance(from: location) < $1.location.distance(from: location)})
                filteredMemoList.sort(by: {$0.location.distance(from: location) < $1.location.distance(from: location)})
                
            } else {
                memoList.sort(by: {$0.date > $1.date})
                filteredMemoList.sort(by: {$0.date > $1.date})
            }
            if filteredProfilList.count == filteredProfilList.count {
                var filtered: [Profile] = []
                
                for (idx, memo) in filteredMemoList.enumerated() {
                    if filteredProfilList[idx].id == memo.userUid {
                        filtered.append(filteredProfilList[idx])
                    } else {
                        if let new = filteredProfilList.first(where: {$0.id == memo.userUid}) {
                            filtered.append(new)
                        }
                    }
                }
                filteredProfilList = filtered
            }
            if memoWriterList.count == memoList.count {
                var temp: [Profile] = []
                
                for (idx, memo) in memoList.enumerated() {
                    if memoWriterList[idx].id == memo.userUid {
                        temp.append(memoWriterList[idx])
                    } else {
                        if let new = memoWriterList.first(where: {$0.id == memo.userUid}) {
                            temp.append(new)
                        }
                    }
                }
                memoWriterList = temp
                
            }
        }
    }
    /// 메모가 선택되었을 때 action
    /// - Parameters:
    ///   - memo : 선택된 Memo
    /// - Returns: void, 선택된 메모를 가지고 이 메모를 포함하는 클러스터 위치, 만약 그 클러스터가 현재 맵에 없다면, 메모의 위치로 카메라를 이동하는 함수
    func memoDidSelect(memo: Memo) {
        operationQueue.cancelAllOperations()
        withAnimation {
            self.selectedMemoId = memo.id
            
            if let containing = clusters.first(where: {$0.memos.contains(where: {$0.id == memo.id})}) {
                self.mapPosition = MapCameraPosition.camera(.init(centerCoordinate: containing.center, distance: cameraDistance ?? 1000))
            } else {
                let memoCoord = CLLocationCoordinate2D(latitude: memo.location.latitude, longitude: memo.location.longitude)
                self.mapPosition = MapCameraPosition.camera(.init(centerCoordinate: memoCoord, distance: cameraDistance ?? 1000))
                
            }
        }
    }
    func clusterDidSelected(cluster: MemoCluster) {
        let memo = cluster.memos.first!
        self.selectedMemoId = memo.id
        withAnimation {

        self.mapPosition = MapCameraPosition.camera(.init(centerCoordinate: cluster.center, distance: cameraDistance ?? 1000))
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
//MARK: - Map 관련 로직

/// 카메라가 변경되었을 때 호출되는 함수
/// - Parameters:
///   - boundWidth : 현재 호출하는 Map()의 width값
///   - context: onMapCameraChange를 통해 확인할 수 있는 camera update context
/// - Returns: void, 클러스터를 업데이트 하는 함수를 호출
///
extension MainMapViewModel {
    func setCamera(boundWidth: Double, context: MapCameraUpdateContext) {
        self.cameraDistance = context.camera.distance
        self.mapBoundWidth = boundWidth
        self.currentCameraMapContext = context
    }
}
//MARK: - Clustering 관련 Logics
extension MainMapViewModel {
    /// 카메라가 변경되었을 때 호출되는 함수
    /// - Parameters:
    ///   - boundWidth : 현재 호출하는 Map()의 width값
    ///   - context: onMapCameraChange를 통해 확인할 수 있는 camera update context
    /// - Returns: void, 클러스터를 업데이트 하는 함수를 호출
    func cameraDidChange(boundWidth: Double, context: MapCameraUpdateContext) {
        
        self.cameraDistance = context.camera.distance
        let contextWidth = context.rect.width
        updateCluster(mapRect: context.rect, zoomScale: Double(boundWidth/contextWidth))
    }
    /// 클러스터가 완료되었을 때 호출되는 Delegate함수
    /// - Parameters:
    ///   - clusters : 클러스터링 완료 된 클러스터들
    /// - Returns: void, view에 바인딩되는 self.clusters를 변경함
    ///
    ///특이사항으로는 보라 경고가 떠서 async하게 감싸줬음. 끝
    func displayClusters(clusters: [MemoCluster]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            
            if clusters != self.clusters {
                self.clusters = clusters
                self.clusteringDidChanged = true
            } else {
                self.clusteringDidChanged = false
            }
        }
    }
    /// 맵 좌하단에 버튼을 눌렀을 때 현재 위치로 최신화 하는 기능
    /// - Returns: void, 카메라를 현재 위치로 이동시킴
    func switchUserLocation() {
//        self.mapPosition = MapCameraPosition.camera(.init(centerCoordinate: location!.coordinate, distance: cameraDistance ?? 1000))
//        mapPosition = MapCameraPosition.userLocation(followsHeading: false, fallback: .automatic)
        if let coord = location?.coordinate {
            self.mapPosition = MapCameraPosition.camera(.init(centerCoordinate: coord, distance: cameraDistance ?? MemoService.shared.queryArea * 5))
        }
        if !self.isUserTracking {
            self.isUserTracking = true
            
        }
    }
    // 오류나서 일단 주석
    /// 클러스터를 업데이트 하는 함수
    /// - Parameters:
    ///   - mapRect : 현재 바라보는 지도의 MKMapRect값
    ///   - zoomScale : 현재 지도 Map의 widthSize로 MapRect를 나눈 값
    /// - Returns: Void, 클러스터 오퍼레이션의 클러스터링을 수행하는 함수를 호출
    func updateCluster(mapRect: MKMapRect, zoomScale: Double) {
        cluster.clusterMemosWithMapRect(visibleMapRect: mapRect, zoomScale: zoomScale)
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



