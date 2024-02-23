//
//  OtherUserViewModel.swift
//  MyMemory
//
//  Created by 정정욱 on 2/2/24.


import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import CoreLocation



class OtherUserViewModel: ObservableObject, ProfileViewModelProtocol {
    
    @Published var memoList: [Memo] = []
    @Published var selectedFilter = SortedTypeOfMemo.last
    @Published var isShowingOptions = false
    @Published var isCurrentUserLoginState = false
    //  let db = Firestore.firestore()
    let memoService = MemoService.shared
    let locationHandler = LocationsHandler.shared
    @Published var user: User?
    @Published var currentLocation: CLLocation?  = nil
    @Published var memoCreator: Profile? = nil
    @Published var isEmptyView = false
    var lastDocument: QueryDocumentSnapshot? = nil
    
    init() {
        fetchUserState()
        self.isCurrentUserLoginState = fetchCurrentUserLoginState()
        
        
        // 현재 유져 정보, 위치 체크하기
        user = AuthService.shared.currentUser
        fetchCurrentUserLocation { location in
            if let location = location {
                self.currentLocation = location
            }
        }
        //        AuthViewModel.shared.fetchUser{ user in
        //            self.user = user
        //        }
    }
    
    // 여기 이동 프로필 사용자 메모만 볼 수 있게 구현하기
    func fetchMemoCreatorProfile(memoCreator: User) async {
        self.memoCreator = await AuthService.shared.memoCreatorfetchProfile(uid: memoCreator.id ?? "")

        // memoList memoCreator메모 가져오기
//        self.memoList = []
        fetchUserState()

        // 백그라운드에서 데이터 가져오기
        self.memoList = await self.memoService.fetchProfileMemos(userID: memoCreator.id ?? "")
        self.isEmptyView = self.memoList.isEmpty
        DispatchQueue.main.async {
            Task {[weak self] in
                guard let self = self else { return }
                guard let userId = self.memoCreator?.id else { 
                    print("ID 없음")
                    return
                }
//                await self.pagenate(userID: userId)
            }
        }

        fetchCurrentUserLocation { location in
            if let location = location {
                // 메인 스레드에서 UI 업데이트
                DispatchQueue.main.async {
                    self.currentLocation = location
                }
            }
        }
    }
    func fetchCurrentUserLocation(returnCompletion: @escaping (CLLocation?) -> Void) {
        locationHandler.getCurrentLocation { [weak self] location in
            DispatchQueue.main.async {
                if let location = location {
                    print("현재 위치", location)
                    returnCompletion(CLLocation(
                        latitude: location.latitude,
                        longitude: location.longitude
                    ))
                    print("주소 불러오기 완료", LoadingManager.shared.phase)
                } else {
                    returnCompletion(nil)
                }
            }
        }
    }
    /// MypageView에서 사용하는 memolist에 페이지네이션한 개수만큼 추가하는 함수
    /// - Parameters:
    ///     - userID: 사용자 UID
    func pagenate(userID: String) async {
        //        if self.user?.id != userID {
//        let fetchedMemos = await self.memoService.fetchMemos(userID: userID, lastDocument: self.lastDocument) { last in
//            self.lastDocument = last
//        }
//        await MainActor.run {
//            self.memoList += fetchedMemos
//        }
    }
}
