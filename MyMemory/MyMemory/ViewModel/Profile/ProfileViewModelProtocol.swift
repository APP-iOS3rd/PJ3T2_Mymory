//
//  MemoListViewModel.swift
//  MyMemory
//
//  Created by 정정욱 on 2/2/24.
//

import SwiftUI
import _PhotosUI_SwiftUI
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore



protocol ProfileViewModelProtocol: ObservableObject {
    
    var memoList: [Memo] { get set }
    var selectedFilter: SortedTypeOfMemo { get set }
    var isShowingOptions: Bool { get set }
    var isCurrentUserLoginState: Bool { get set }
    var user: User? { get set }
    
    var currentLocation: CLLocation? { get set }
    var lastDocument: QueryDocumentSnapshot? { get set }


    func fetchDistanceOfUserAndMemo(myLocation: CLLocationCoordinate2D, memoLocation: Location) -> Double
    func sortMemoList(type: SortedTypeOfMemo)
    func fetchUserState()
    func fetchCurrentUserLoginState() -> Bool
    func fetchCurrentUserLocation(returnCompletion: @escaping (CLLocation?) -> Void)
    func pagenate(userID: String) async
}

extension ProfileViewModelProtocol {
    func fetchUserState() {
        guard let _ = UserDefaults.standard.string(forKey: "userId") else { return }
    }
    
    func fetchCurrentUserLoginState() -> Bool {
        if let _ = Auth.auth().currentUser {
            return true
        }
        return false
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

}
