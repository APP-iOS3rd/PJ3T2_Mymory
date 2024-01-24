//
//  MyPageViewModel.swift
//  MyMemory
//
//  Created by 이명섭 on 1/4/24.
//

import Foundation
import _PhotosUI_SwiftUI
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore



class MypageViewModel: ObservableObject {
    
    @Published var memoList: [Memo] = []
    @Published var selectedFilter = SortedTypeOfMemo.last
    @Published var isShowingOptions = false
    @Published var selectedImage: PhotosPickerItem? = nil
    @Published var selectedPhotoData: Data? = nil
    @Published var isCurrentUserLoginState = false
    
    let db = Firestore.firestore()
    let memoService = MemoService.shared
    let locationHandler = LocationsHandler.shared
    
    @Published var user: User
    var currentLocation: CLLocation? {
        didSet {
            self.fetchMyMemoList()
        }
    }
    
    init(user: User) {
        self.user = user
        fetchUserState()
        //self.isCurrentUserLoginState = fetchCurrentUserLoginState()
        fetchCurrentUserLocation()
    }
    
    // MARK: 현재 사용의 위치(위도, 경도)와 메모의 위치, 그리고 설정할 거리를 통해 설정된 거리 내 메모를 필터링하는 함수(CLLocation의 distance 메서드 사용)
    func fetchDistanceOfUserAndMemo(myLocation: CLLocationCoordinate2D, memoLocation: Location ) -> Double {
        // 사용자의 위치를 CLLocation객체로 생성
        let location = CLLocationCoordinate2D(latitude: memoLocation.latitude, longitude: memoLocation.longitude)
        return location.distance(to: myLocation)
    }
    
    // MARK: MemoList 필터링 & 정렬하는 메서드입니다
    func sortMemoList(type: SortedTypeOfMemo) {
        self.selectedFilter = type
        switch type {
        case .last:
            self.memoList = memoList.sorted {
                let first = Date(timeIntervalSince1970: $0.date)
                let second = Date(timeIntervalSince1970: $1.date)
                // 시간비교 orderedAscending: first가 second보다 이전(빠른), orderedDescending: first가 second보다 이후(늦은)
                switch first.compare(second) {
                case .orderedAscending: return false
                case .orderedDescending: return true
                case .orderedSame: return true
                }
            }
        case .like:
            self.memoList = memoList.sorted { $0.likeCount > $1.likeCount }
        case .close:
            self.memoList = memoList.sorted {
                let first = $0.location.distance(from: currentLocation ?? CLLocation(latitude: 37.5664056, longitude: 126.9778222))
                let second = $1.location.distance(from: currentLocation ?? CLLocation(latitude: 37.5664056, longitude: 126.9778222))
                return first < second
            }
        }
    }
    func fetchUserState() {
        guard let _ = user.id else { return }
    }
    
    func fetchCurrentUserLoginState() -> Bool {
        if let _ = Auth.auth().currentUser {
            return true
        }
        return false
    }
    
    func fetchMyMemoList() {
        if let userID = self.user.id {
            LoadingManager.shared.phase = .loading
            Task { [weak self] in
                guard let self = self else {return}
                self.memoList = await self.memoService.fetchMyMemos(userID: userID)
                LoadingManager.shared.phase = .success
            }
        } else {
            LoadingManager.shared.phase = .fail(msg: "로그인 중이 아닙니다.")
        }
    }
    
    func fetchCurrentUserLocation() {
        LoadingManager.shared.phase = .loading
        locationHandler.getCurrentLocation { [weak self] location in
            DispatchQueue.main.async {
                if let location = location {
                    print("현재 위치", location)
                    self?.currentLocation = CLLocation(
                        latitude: location.latitude,
                        longitude: location.longitude
                    )
                    LoadingManager.shared.phase = .success
                } else {
                    LoadingManager.shared.phase = .fail(msg: "위치 정보 획득 실패")
                }
            }
        }
    }
}
