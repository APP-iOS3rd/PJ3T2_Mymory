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
    
    @Published var merkerMemoList: [Memo] = []
    @Published var memoList: [Memo] = []
    @Published var selectedFilter = SortedTypeOfMemo.last
    @Published var isShowingOptions = false

    @Published var isCurrentUserLoginState = false
    //  let db = Firestore.firestore()
    let memoService = MemoService.shared
    let locationHandler = LocationsHandler.shared
    @Published var user: User?
    @Published var currentLocation: CLLocation?  = nil
    
    @Published var memoCreator: User = User(email: "", name: "")
    
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
    func fetchMemoCreatorProfile(fromDetail: Bool, memoCreator: User){
        self.memoList = []
        self.memoCreator = memoCreator
        
        if fromDetail == true {
            fetchUserState()
            DispatchQueue.main.async {
                Task {[weak self] in
                    guard let self = self else {return}
                    await self.pagenate(userID: memoCreator.id ?? "")
                }
            }
 
            fetchCurrentUserLocation { location in
                if let location = location {
                    self.currentLocation = location
                }
            }
        }
           
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
        
        let fetchedMemos = await self.memoService.fetchMyMemos(userID: userID, lastDocument: self.lastDocument) { last in
            self.lastDocument = last
        }
        
        await MainActor.run {
            self.memoList += fetchedMemos
        }
    }
}
