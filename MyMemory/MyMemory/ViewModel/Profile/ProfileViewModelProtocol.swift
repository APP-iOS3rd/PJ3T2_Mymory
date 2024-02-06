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
    
    var merkerMemoList: [Memo] { get set } 
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
}
