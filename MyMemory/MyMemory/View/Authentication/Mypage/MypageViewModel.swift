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

  //  let db = Firestore.firestore()
    let memoService = MemoService.shared
    @Published var user: User?
    
    init() {
        fetchUserState()
        //self.isCurrentUserLoginState = fetchCurrentUserLoginState()
        
        if let userID = UserDefaults.standard.string(forKey: "userId") {
            Task {[weak self] in
                guard let self = self else {return}
                self.memoList = await self.memoService.fetchMyMemos(userID: userID)
            }
        }
        let user = AuthViewModel.shared.currentUser
        AuthViewModel.shared.fetchUser()
//        AuthViewModel.shared.fetchUser()

        
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
                let first = fetchDistanceOfUserAndMemo(myLocation: CLLocationCoordinate2D(latitude: 37.5664056, longitude: 126.9778222), memoLocation: $0.location)
                let second = fetchDistanceOfUserAndMemo(myLocation: CLLocationCoordinate2D(latitude: 37.5664056, longitude: 126.9778222), memoLocation: $1.location)
                return first < second
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
  
//    func fetchUserInfoFromUserDefaults() -> UserInfo? {
//        if let savedData = UserDefaults.standard.object(forKey: "userInfo") as? Data {
//            let decoder = JSONDecoder()
//            
//            if let userInfo = try? decoder.decode(UserInfo.self, from: savedData) {
//                return userInfo
//            } else {
//                return nil
//            }
//        } else {
//            return nil
//        }
//    }
    
    func fetchMyMemoList() async {

        if let userId = UserDefaults.standard.string(forKey: "userId") {
            
            self.memoList = await memoService.fetchMyMemos(userID: userId)

        } else {

            print("로그인 중이 아닙니다.")
        }
    }
}
